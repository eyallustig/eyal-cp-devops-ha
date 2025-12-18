import json
import logging
import signal
import time
from dataclasses import dataclass
from datetime import datetime, timezone
from threading import Event
from typing import Optional

import boto3
from botocore.config import Config
from botocore.exceptions import BotoCoreError, ClientError

from settings import get_settings

stop_event = Event()


@dataclass
class SqsMessage:
    message_id: str
    receipt_handle: str
    body_raw: str


@dataclass
class Context:
    settings: object
    logger: logging.Logger
    sqs_client: object
    s3_client: object


def _handle_stop(signum, frame):
    ctx = _get_context_or_none()
    if ctx:
        ctx.logger.info("Received signal %s, stopping worker loop", signum)
    stop_event.set()


def create_context():
    settings = get_settings()

    logging.basicConfig(level=settings.log_level)
    logger = logging.getLogger("worker")

    session = boto3.session.Session()
    client_args = {"region_name": settings.aws_region}
    if settings.aws_endpoint_url:
        client_args["endpoint_url"] = settings.aws_endpoint_url

    retry_config = Config(
        retries={
            "max_attempts": settings.aws_max_retries,
            "mode": "standard",
        }
    )

    sqs_client = session.client("sqs", config=retry_config, **client_args)
    s3_client = session.client("s3", config=retry_config, **client_args)

    return Context(
        settings=settings,
        logger=logger,
        sqs_client=sqs_client,
        s3_client=s3_client,
    )


_context: Optional[Context] = None


def _get_context_or_none() -> Optional[Context]:
    return _context


def get_context() -> Context:
    if _context is None:
        raise RuntimeError("Context not initialized. Call main() or set _context first.")
    return _context


def receive_messages(ctx: Context) -> list[SqsMessage]:
    try:
        response = ctx.sqs_client.receive_message(
            QueueUrl=ctx.settings.sqs_queue_url,
            MaxNumberOfMessages=ctx.settings.max_messages,
            WaitTimeSeconds=ctx.settings.poll_wait_seconds,
            VisibilityTimeout=ctx.settings.visibility_timeout,
        )
    except (ClientError, BotoCoreError):
        ctx.logger.exception("Failed to receive messages from SQS")
        return []

    messages = response.get("Messages", [])
    return [
        SqsMessage(
            message_id=m["MessageId"],
            receipt_handle=m["ReceiptHandle"],
            body_raw=m["Body"],
        )
        for m in messages
    ]


def build_s3_key(ctx: Context, body: dict, message_id: str) -> str:
    raw_ts: Optional[object] = body.get("email_timestream")
    try:
        ts_int = int(raw_ts)
    except (TypeError, ValueError):
        raise ValueError("email_timestream must be a unix timestamp")

    processing_dt = datetime.now(tz=timezone.utc)
    prefix = f"emails/v1/{ctx.settings.app_env}/{processing_dt:%Y}/{processing_dt:%m}/{processing_dt:%d}/"
    filename = f"{ts_int}_msgid={message_id}.json"
    return prefix + filename


def object_exists(ctx: Context, key: str) -> bool:
    try:
        ctx.s3_client.head_object(Bucket=ctx.settings.s3_bucket, Key=key)
        return True
    except ctx.s3_client.exceptions.NoSuchKey:
        return False
    except (ClientError, BotoCoreError):
        # If head fails for other reasons, treat as not existing to allow upload; errors will surface then.
        return False


def upload_to_s3(ctx: Context, body_json: str, key: str) -> None:
    ctx.s3_client.put_object(
        Bucket=ctx.settings.s3_bucket,
        Key=key,
        Body=body_json.encode("utf-8"),
        ContentType="application/json",
    )


def process_message(ctx: Context, message: SqsMessage) -> bool:
    try:
        body = json.loads(message.body_raw)
    except json.JSONDecodeError:
        ctx.logger.exception("Invalid JSON body for message %s", message.message_id)
        return False

    try:
        key = build_s3_key(ctx, body, message.message_id)
    except ValueError as exc:
        ctx.logger.error("Failed to build S3 key for message %s: %s", message.message_id, exc)
        return False

    try:
        already_exists = object_exists(ctx, key)
    except Exception:
        ctx.logger.exception("Failed to check existing object for message %s", message.message_id)
        already_exists = False

    if not already_exists:
        try:
            upload_to_s3(ctx, message.body_raw, key)
            ctx.logger.info("Uploaded message %s to s3://%s/%s", message.message_id, ctx.settings.s3_bucket, key)
        except (ClientError, BotoCoreError):
            ctx.logger.exception("Failed to upload message %s to S3", message.message_id)
            return False
    else:
        ctx.logger.info("Object already exists for message %s, skipping upload", message.message_id)

    try:
        ctx.sqs_client.delete_message(
            QueueUrl=ctx.settings.sqs_queue_url,
            ReceiptHandle=message.receipt_handle,
        )
        ctx.logger.info("Deleted message %s from SQS", message.message_id)
    except (ClientError, BotoCoreError):
        ctx.logger.exception("Failed to delete message %s from SQS", message.message_id)
        return False

    return True


def worker_loop(ctx: Context):
    ctx.logger.info(
        "Starting worker: queue=%s bucket=%s env=%s",
        ctx.settings.sqs_queue_url,
        ctx.settings.s3_bucket,
        ctx.settings.app_env,
    )
    while not stop_event.is_set():
        messages = receive_messages(ctx)
        if not messages:
            time.sleep(ctx.settings.sleep_on_empty_seconds)
            continue

        for msg in messages:
            success = process_message(ctx, msg)
            if not success:
                continue


def main():
    global _context
    _context = create_context()
    signal.signal(signal.SIGTERM, _handle_stop)
    signal.signal(signal.SIGINT, _handle_stop)
    worker_loop(_context)


if __name__ == "__main__":
    main()
