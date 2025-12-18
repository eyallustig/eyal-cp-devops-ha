import json
import os
import random
import time
import uuid

import requests

API_URL = os.environ.get("API_URL", "http://localhost:8000/ingest")
TOKEN = os.environ.get("TOKEN", "local-dev-token")

EMAILS = ["a@example.com", "b@example.com", "c@example.com"]
SUBJECTS = ["Hi", "Hello", "Update", "Reminder"]
SENDERS = ["Alice", "Bob", "Carol", "Dave"]


def make_good_payload():
    # spread timestamps a bit for better coverage
    now_ts = int(time.time()) + random.randint(-300, 300)
    return {
        "data": {
            "email_subject": random.choice(SUBJECTS),
            "email_sender": random.choice(SENDERS),
            "email_timestream": now_ts,
            "email_content": f"Message {uuid.uuid4()}",
        },
        "token": TOKEN,
    }


def make_bad_token():
    payload = make_good_payload()
    payload["token"] = "bad-token"
    return payload


def make_missing_token():
    payload = make_good_payload()
    payload.pop("token", None)
    return payload


def make_bad_timestream():
    payload = make_good_payload()
    payload["data"]["email_timestream"] = "not-a-number"
    return payload


def make_missing_timestream():
    payload = make_good_payload()
    payload["data"].pop("email_timestream", None)
    return payload


def send_payload(payload, idx):
    try:
        r = requests.post(API_URL, json=payload, timeout=5)
        print(idx, r.status_code, r.text)
    except Exception as exc:
        print(idx, "error", exc)


def main():
    # Define a mix of good and bad payloads
    payloads = []
    for _ in range(10):
        payloads.append(make_good_payload())
    payloads.append(make_bad_token())
    payloads.append(make_missing_token())
    payloads.append(make_bad_timestream())
    payloads.append(make_missing_timestream())

    for idx, payload in enumerate(payloads):
        send_payload(payload, idx)
        time.sleep(0.1)


if __name__ == "__main__":
    main()
