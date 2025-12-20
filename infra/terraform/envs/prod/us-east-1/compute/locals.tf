locals {
  project     = var.project
  environment = var.environment
  region      = var.region

  name_prefix = "${local.project}-${local.environment}"

  base_tags = merge(
    {
      Project     = local.project
      Environment = local.environment
      ManagedBy   = "Terraform"
    },
    var.owner == null ? {} : { Owner = var.owner }
  )

  tags = merge(local.base_tags, var.extra_tags)

  # ECR repository names
  ecr_api_repo_name    = "${local.name_prefix}-api"
  ecr_worker_repo_name = "${local.name_prefix}-worker"

  # Worker is allowed to write only under this S3 prefix (dates can vary below it)
  s3_write_prefix = "emails/${var.payload_version}/${local.environment}/"
}
