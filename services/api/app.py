import json
import logging
from datetime import datetime, timezone
from typing import Optional, Union

import boto3
from botocore.config import Config
from botocore.exceptions import BotoCoreError, ClientError
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

from .settings import get_settings

settings = get_settings()

logging.basicConfig(level=settings.log_level)
logger = logging.getLogger("api")

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

ssm_client = session.client("ssm", config=retry_config, **client_args)
sqs_client = session.client("sqs", config=retry_config, **client_args)

app = FastAPI(title="Ingest API", version="0.1.0")


class IngestData(BaseModel):
    email_subject: str
    email_sender: str
    email_timestream: Union[int, str]
    email_content: str


class IngestRequest(BaseModel):
    data: IngestData
    token: Optional[str] = None


@app.get("/healthz")
def healthz():
    return {"status": "ok"}


def get_expected_token() -> str:
    try:
        response = ssm_client.get_parameter(
            Name=settings.ssm_token_param,
            WithDecryption=True,
        )
        return response["Parameter"]["Value"]
    except ssm_client.exceptions.ParameterNotFound as exc:
        logger.error("SSM parameter %s not found", settings.ssm_token_param)
        raise HTTPException(status_code=500, detail="Token parameter not found") from exc
    except (ClientError, BotoCoreError) as exc:
        logger.exception("Failed to retrieve token from SSM")
        raise HTTPException(status_code=500, detail="Failed to retrieve token") from exc


def validate_timestamp(raw_timestamp: Union[int, str]) -> int:
    try:
        ts = int(raw_timestamp)
    except (TypeError, ValueError) as exc:
        raise HTTPException(
            status_code=400,
            detail="email_timestream must be a unix timestamp",
        ) from exc
    return ts


@app.post("/ingest")
def ingest(payload: IngestRequest):
    if not payload.token:
        raise HTTPException(status_code=401, detail="Token is required")

    expected_token = get_expected_token()
    if payload.token != expected_token:
        raise HTTPException(status_code=403, detail="Invalid token")

    validate_timestamp(payload.data.email_timestream)

    message = payload.data.dict()
    message["received_at"] = datetime.now(tz=timezone.utc).isoformat()

    try:
        response = sqs_client.send_message(
            QueueUrl=settings.sqs_queue_url,
            MessageBody=json.dumps(message),
        )
    except (ClientError, BotoCoreError) as exc:
        logger.exception("Failed to send message to SQS")
        raise HTTPException(status_code=500, detail="Failed to publish message") from exc

    return {
        "status": "accepted",
        "message_id": response.get("MessageId"),
        "received_at": message["received_at"],
    }
