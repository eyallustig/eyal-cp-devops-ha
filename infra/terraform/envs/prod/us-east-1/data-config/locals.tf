data "aws_caller_identity" "current" {}

locals {
  project     = var.project
  environment = var.environment
  region      = var.region

  name_prefix = "${local.project}-${local.environment}"

  account_id  = data.aws_caller_identity.current.account_id

  base_tags = merge(
    {
      Project     = local.project
      Environment = local.environment
      ManagedBy   = "Terraform"
    },
    var.owner == null ? {} : { Owner = var.owner }
  )

  tags = merge(local.base_tags, var.extra_tags)

  # S3 payload bucket must be globally unique
  payload_bucket_name = "${local.name_prefix}-${local.region}-payload-${local.account_id}"

  # SQS names are account/region-scoped (not global)
  emails_queue_name = "${local.name_prefix}-${local.region}-emails-queue"
  emails_dlq_name   = "${local.name_prefix}-${local.region}-emails-dlq"

  # SSM parameter name (path-style)
  token_param_name = "/${local.project}/${local.environment}/token"
}
