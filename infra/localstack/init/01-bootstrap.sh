#!/bin/bash
set -euo pipefail

export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_REGION=${AWS_REGION:-us-east-1}

TOKEN_VALUE="${BOOTSTRAP_TOKEN:-local-dev-token}"
TOKEN_PARAM="${BOOTSTRAP_TOKEN_PARAM:-/eyal-cp-devops-ha/local/token}"
BUCKET_NAME="${BOOTSTRAP_BUCKET:-eyal-cp-devops-ha-local}"
QUEUE_NAME="${BOOTSTRAP_QUEUE:-eyal-cp-devops-ha-local-emails-queue}"
DLQ_NAME="${BOOTSTRAP_DLQ:-eyal-cp-devops-ha-local-emails-dlq}"

echo "Creating S3 bucket: ${BUCKET_NAME}"
awslocal s3api create-bucket --bucket "${BUCKET_NAME}" --region "${AWS_REGION}" >/dev/null || true

echo "Creating SSM parameter: ${TOKEN_PARAM}"
awslocal ssm put-parameter \
  --name "${TOKEN_PARAM}" \
  --type SecureString \
  --value "${TOKEN_VALUE}" \
  --overwrite >/dev/null

echo "Creating SQS DLQ: ${DLQ_NAME}"
awslocal sqs create-queue --queue-name "${DLQ_NAME}" >/dev/null || true
DLQ_URL=$(awslocal sqs get-queue-url --queue-name "${DLQ_NAME}" --query 'QueueUrl' --output text)
DLQ_ARN=$(awslocal sqs get-queue-attributes --queue-url "${DLQ_URL}" --attribute-names QueueArn --query 'Attributes.QueueArn' --output text)

echo "Creating SQS queue: ${QUEUE_NAME} with DLQ redrive policy"
REDRIVE_POLICY=$(printf '{"deadLetterTargetArn":"%s","maxReceiveCount":"5"}' "${DLQ_ARN}")

ESCAPED_REDRIVE_POLICY=$(printf '%s' "${REDRIVE_POLICY}" | sed 's/"/\\"/g')

awslocal sqs create-queue \
  --queue-name "${QUEUE_NAME}" \
  --attributes "{\"RedrivePolicy\":\"${ESCAPED_REDRIVE_POLICY}\"}" >/dev/null


echo "LocalStack bootstrap complete."
