variable "project" {
  description = "Project name (used for naming and tagging)."
  type        = string
  default     = "eyal-cp-devops-ha"
}

variable "environment" {
  description = "Environment name (e.g., prod, staging, dev)."
  type        = string
  default     = "prod"
}

variable "region" {
  description = "AWS region for this stack."
  type        = string
  default     = "us-east-1"
}

variable "owner" {
  description = "Optional Owner tag (person or team)."
  type        = string
  default     = null
}

variable "extra_tags" {
  description = "Additional tags to merge into the default tag set."
  type        = map(string)
  default     = {}
}

# ----------------------------
# ECR settings
# ----------------------------
variable "ecr_force_delete" {
  description = "If true, allow Terraform to delete the ECR repositories even if they contain images (useful for cleanup)."
  type        = bool
  default     = false
}

variable "ecr_max_tagged_images" {
  description = "How many tagged images to keep per repository."
  type        = number
  default     = 5

  validation {
    condition     = var.ecr_max_tagged_images >= 1
    error_message = "ecr_max_tagged_images must be >= 1."
  }
}

variable "ecr_expire_untagged_after_days" {
  description = "Expire untagged images older than N days."
  type        = number
  default     = 3

  validation {
    condition     = var.ecr_expire_untagged_after_days >= 1
    error_message = "ecr_expire_untagged_after_days must be >= 1."
  }
}

# ----------------------------
# Remote state (read data-config outputs)
# ----------------------------
variable "remote_state_bucket" {
  description = "S3 bucket that stores Terraform remote state (from bootstrap outputs)."
  type        = string
}

variable "data_config_state_key" {
  description = "Remote state key for the data-config stack."
  type        = string
  default     = "data-config/prod/us-east-1/terraform.tfstate"
}

# ----------------------------
# Payload naming
# ----------------------------
variable "payload_version" {
  description = "Payload schema version used for S3 key prefixing."
  type        = string
  default     = "v1"
}

variable "api_image_tag" {
  description = "Image tag for API service (e.g., git SHA7)."
  type        = string
}

variable "worker_image_tag" {
  description = "Image tag for Worker service (e.g., git SHA7)."
  type        = string
}

variable "api_desired_count" {
  description = "Desired count for API ECS service."
  type        = number
  default     = 1
}

variable "worker_desired_count" {
  description = "Desired count for Worker ECS service."
  type        = number
  default     = 1
}

variable "assign_public_ip" {
  description = "Assign a public IP to ECS tasks (simple default VPC approach; ALB comes later)."
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention days for ECS services."
  type        = number
  default     = 3
}

variable "aws_max_retries" {
  description = "Max retries for AWS SDK calls."
  type        = number
  default     = 5
}

variable "log_level" {
  description = "Log level for services."
  type        = string
  default     = "INFO"
}

variable "worker_poll_wait_seconds" {
  type        = number
  default     = 20
  description = "SQS long poll wait time."
}

variable "worker_sleep_on_empty_seconds" {
  type        = number
  default     = 2
  description = "Sleep duration when the queue is empty."
}

variable "worker_visibility_timeout" {
  type        = number
  default     = 60
  description = "Visibility timeout used by worker logic (should match queue setting)."
}

variable "worker_max_messages" {
  type        = number
  default     = 10
  description = "Max messages per ReceiveMessage call."
}
