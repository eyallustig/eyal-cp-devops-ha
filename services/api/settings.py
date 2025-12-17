from functools import lru_cache
from typing import Optional

from pydantic import BaseSettings, Field


class Settings(BaseSettings):
    aws_region: str = Field(..., env="AWS_REGION")
    aws_endpoint_url: Optional[str] = Field(None, env="AWS_ENDPOINT_URL")
    ssm_token_param: str = Field(..., env="SSM_TOKEN_PARAM")
    sqs_queue_url: str = Field(..., env="SQS_QUEUE_URL")
    aws_max_retries: int = Field(5, env="AWS_MAX_RETRIES")
    log_level: str = Field("INFO", env="LOG_LEVEL")

    class Config:
        env_file = ".env"


@lru_cache()
def get_settings() -> Settings:
    return Settings()
