from functools import lru_cache
from typing import Optional

from pydantic import BaseSettings, Field


class Settings(BaseSettings):
    aws_region: str = Field(..., env="AWS_REGION")
    aws_endpoint_url: Optional[str] = Field(None, env="AWS_ENDPOINT_URL")
    aws_max_retries: int = Field(5, env="AWS_MAX_RETRIES")
    sqs_queue_url: str = Field(..., env="SQS_QUEUE_URL")
    s3_bucket: str = Field(..., env="S3_BUCKET")
    app_env: str = Field("local", env="APP_ENV")
    poll_wait_seconds: int = Field(20, env="POLL_WAIT_SECONDS")
    sleep_on_empty_seconds: int = Field(2, env="SLEEP_ON_EMPTY_SECONDS")
    visibility_timeout: int = Field(60, env="VISIBILITY_TIMEOUT")
    max_messages: int = Field(10, env="MAX_MESSAGES")
    log_level: str = Field("INFO", env="LOG_LEVEL")

    class Config:
        env_file = ".env"


@lru_cache()
def get_settings() -> Settings:
    return Settings()
