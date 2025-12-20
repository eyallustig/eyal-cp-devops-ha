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
# S3 payload bucket settings
# ----------------------------
variable "payload_noncurrent_version_expiration_days" {
  description = "How many days to keep noncurrent (versioned) objects in the payload bucket."
  type        = number
  default     = 30

  validation {
    condition     = var.payload_noncurrent_version_expiration_days >= 1
    error_message = "payload_noncurrent_version_expiration_days must be >= 1."
  }
}

variable "payload_object_expiration_days" {
  description = "Expire current payload objects after N days."
  type        = number
  default     = 30

  validation {
    condition     = var.payload_object_expiration_days >= 1
    error_message = "payload_object_expiration_days must be >= 1."
  }
}

variable "payload_force_destroy" {
  description = "If true, allow Terraform to delete all objects in the payload bucket when destroying it."
  type        = bool
  default     = false
}

# ----------------------------
# SQS settings
# ----------------------------
variable "sqs_visibility_timeout_seconds" {
  description = "Visibility timeout for the main queue."
  type        = number
  default     = 60
}

variable "sqs_receive_wait_time_seconds" {
  description = "Long polling wait time (0-20). Recommended 20."
  type        = number
  default     = 20
}

variable "sqs_message_retention_seconds" {
  description = "Retention period for the main queue (seconds). Default 4 days."
  type        = number
  default     = 345600
}

variable "dlq_message_retention_seconds" {
  description = "Retention period for the DLQ (seconds). Default 14 days."
  type        = number
  default     = 1209600
}

variable "max_receive_count" {
  description = "How many times a message can be received before moving to DLQ."
  type        = number
  default     = 5
}

# ----------------------------
# SSM token parameter settings
# ----------------------------
variable "token_parameter_description" {
  description = "Description for the SSM SecureString token parameter."
  type        = string
  default     = "Application auth token (value set out-of-band; Terraform ignores changes)."
}

variable "token_placeholder_value" {
  description = "Placeholder value for the SSM parameter. Real secret must be set out-of-band."
  type        = string
  default     = "CHANGEME"
  sensitive   = true
}
