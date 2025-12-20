# DevOps Home Assignment - ECS Fargate Ingest Pipeline

This project deploys a small ingestion system on AWS. A FastAPI service receives payloads, validates a token from SSM, and pushes messages to SQS. A worker service consumes from SQS and writes payloads to S3. Infrastructure is managed with Terraform and deployed on ECS Fargate behind an internet-facing ALB.

```mermaid
flowchart LR
  U[User] --> ALB[ALB]
  ALB --> API[FastAPI /ingest]
  API --> SQS[SQS Queue]
  SQS --> W[Worker]
  W --> S3[S3 Bucket]
  API --> SSM[SSM Parameter (token)]
```

## Architecture

- services/api
  - FastAPI service
  - Endpoints:
    - GET /healthz
    - POST /ingest
  - Auth: token is provided in the JSON body under "token"

- services/worker
  - SQS consumer that writes payloads to S3

- infra/terraform
  - bootstrap: remote state backend + GitHub OIDC + IAM roles for CI/CD
  - data-config: S3 payload bucket, SQS queue + DLQ, SSM SecureString token parameter (placeholder value)
  - compute: ECR repos, ECS cluster/services, ALB, security groups, CloudWatch logs
  - stacks: bootstrap at infra/terraform/bootstrap; envs at infra/terraform/envs/<env>/<region>/... (prod/us-east-1)

## Service configuration (essential env vars)

### API (services/api)

Required:

- AWS_REGION
- SSM_TOKEN_PARAM
- SQS_QUEUE_URL

Optional:

- LOG_LEVEL (default: INFO)

### Worker (services/worker)

Required:

- AWS_REGION
- SQS_QUEUE_URL
- S3_BUCKET

Optional:

- APP_ENV (default: local)
- LOG_LEVEL (default: INFO)

For the full configuration options (retries, polling, local endpoints), see services/api/settings.py and services/worker/settings.py.

## Prerequisites

- AWS CLI configured for your account
- Terraform >= 1.6
- GitHub Actions enabled on your fork (for CI/CD-driven deploy)
- Python 3 (only needed for scripts/bulk_ingest.py)

## Security note: token handling

Terraform creates the SSM SecureString parameter with a placeholder value and ignores changes to its value. The real token must be set out-of-band to avoid storing secrets in Terraform state or git.

Get the parameter name and set the real token:

```bash
cd infra/terraform/envs/prod/us-east-1/data-config
PARAM_NAME=$(terraform output -raw token_parameter_name)
aws ssm put-parameter \
  --name "$PARAM_NAME" \
  --type SecureString \
  --value "<TOKEN_FROM_ASSIGNMENT>" \
  --region <AWS_REGION> \
  --overwrite
```

## Deploy to AWS (Terraform)

### Step 1: bootstrap

```bash
cd infra/terraform/bootstrap
cp backend.hcl.example backend.hcl
terraform init -backend-config=backend.hcl -reconfigure
terraform apply
```

Key outputs:
- state_bucket_name
- lock_table_name
- github_oidc_provider_arn
- github_actions_ci_role_arn
- github_actions_cd_role_arn

### Step 2: data-config

```bash
cd infra/terraform/envs/prod/us-east-1/data-config
cp backend.hcl.example backend.hcl
terraform init -backend-config=backend.hcl -reconfigure
terraform apply
```

Key outputs:
- payload_bucket_name
- emails_queue_url
- token_parameter_name

Then set the real token in SSM (see "Security note: token handling" above).

### Step 3: compute

```bash
cd infra/terraform/envs/prod/us-east-1/compute
cp terraform.tfvars.example terraform.tfvars
cp backend.hcl.example backend.hcl
terraform init -backend-config=backend.hcl -reconfigure
```

Update terraform.tfvars (local only, git-ignored):
- remote_state_bucket
- data_config_state_key

Image tags are normally set by CD. For a manual deploy:

```bash
terraform apply \
  -var="api_image_tag=sha-<SHORTSHA>" \
  -var="worker_image_tag=sha-<SHORTSHA>"
```

## CI/CD (GitHub Actions)

GitHub Actions repository variables:

| Variable                 | Used by | Source / Notes                                                     |
| ------------------------ | ------- | ------------------------------------------------------------------ |
| AWS_REGION               | CI/CD   | e.g. us-east-1                                                     |
| AWS_ROLE_TO_ASSUME_CI    | CI      | bootstrap output: github_actions_ci_role_arn                       |
| AWS_ROLE_TO_ASSUME_CD    | CD      | bootstrap output: github_actions_cd_role_arn                       |
| TF_STATE_BUCKET          | CD      | bootstrap output: state_bucket_name                                |
| TF_LOCK_TABLE            | CD      | bootstrap output: lock_table_name                                  |
| TF_STATE_KEY_DATA_CONFIG | CD      | from infra/terraform/envs/prod/us-east-1/data-config/backend.hcl   |
| TF_STATE_KEY_COMPUTE     | CD      | from infra/terraform/envs/prod/us-east-1/compute/backend.hcl       |
| ECR_REPO_API             | CI      | repository name only (NOT the full URL)                            |
| ECR_REPO_WORKER          | CI      | repository name only (NOT the full URL)                            |

ECR_REPO_API/ECR_REPO_WORKER must be the repository name only (example: eyal-cp-devops-ha-prod-api).

### CI workflow (.github/workflows/ci.yml)
- Trigger: push to main with paths in services/api/** or services/worker/**
- Builds and pushes images to ECR tagged sha-<shortsha>
- Required GitHub repo variables: see the table in this section

### CD workflow (.github/workflows/cd.yml)
- Trigger: workflow_run after CI success
- Detects changed services and runs terraform init/validate/plan/apply for compute
- Uses lock timeout and workflow concurrency to avoid state lock issues
- Required GitHub repo variables: see the table in this section

OIDC is used for AWS auth; no long-lived AWS keys are stored in GitHub.

## Testing

Get the ALB endpoint:

```bash
cd infra/terraform/envs/prod/us-east-1/compute
ALB_DNS=$(terraform output -raw alb_dns_name)
```

Health check:

```bash
curl "http://${ALB_DNS}/healthz"
```

API responses (examples):

```text
200 {"status":"accepted","message_id":"<UUID>","received_at":"<RFC3339>"}
401 {"detail":"Token is required"}
403 {"detail":"Invalid token"}
400 {"detail":"email_timestream must be a unix timestamp"}
422 {"detail":[{"loc":["body","data","email_timestream"],"msg":"field required","type":"value_error.missing"}]}
```

Single ingest example (token in JSON body):

```bash
curl -X POST "http://${ALB_DNS}/ingest" \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "email_subject": "Happy new year!",
      "email_sender": "John Doe",
      "email_timestream": 1693561101,
      "email_content": "Just want to say... Happy new year!!!"
    },
    "token": "<TOKEN_FROM_ASSIGNMENT>"
  }'
```

Bulk ingest script:

```bash
python3 -m pip install -r scripts/requirements.txt
TOKEN='<TOKEN_FROM_ASSIGNMENT>' API_URL="http://${ALB_DNS}/ingest" python3 scripts/bulk_ingest.py
```

Verify objects in S3:

```bash
cd infra/terraform/envs/prod/us-east-1/data-config
BUCKET=$(terraform output -raw payload_bucket_name)
aws s3 ls "s3://${BUCKET}/" --recursive
```

Objects are written under emails/<payload_version>/<environment>/ (defaults: emails/v1/prod/).

## Cleanup

Destroy in this order:

```bash
cd infra/terraform/envs/prod/us-east-1/compute
terraform destroy

cd infra/terraform/envs/prod/us-east-1/data-config
terraform destroy

cd infra/terraform/bootstrap
terraform destroy
```

## Troubleshooting

- Stale state lock after a canceled run: terraform force-unlock <LOCK_ID>
- Running manually / in a fork: ensure backend.hcl and terraform.tfvars exist for the compute stack (CD generates ci.auto.tfvars at runtime and uses -input=false).
- API returns 403 Invalid token: the SSM parameter still has the placeholder value; update it via aws ssm put-parameter
- ECS rollout did not pick up a new image: check the ECS service deployment and task definition revision

## Assumptions (home assignment)

- Uses the default VPC and an internet-facing ALB to keep scope/cost low.
- Services may run with public IPs; a production setup would use private subnets + NAT/VPC endpoints.
- ALB is HTTP-only to avoid domain/ACM setup; production would enforce HTTPS.
