variable "name_prefix" {
  description = "Prefix used for naming IAM resources"
  type        = string
}

variable "tags" {
  description = "Tags to apply to IAM resources"
  type        = map(string)
}

variable "sqs_queue_arn" {
  description = "ARN of the primary SQS queue"
  type        = string
}

variable "ssm_parameter_arn" {
  description = "ARN of the SecureString parameter to read"
  type        = string
}

variable "s3_bucket_arn" {
  description = "S3 bucket ARN (arn:aws:s3:::bucket-name)"
  type        = string
}

variable "s3_write_prefix" {
  description = "S3 object key prefix within the bucket to allow writes; must be non-empty and end with /"
  type        = string

  validation {
    condition     = length(trimspace(var.s3_write_prefix)) > 0 && endswith(var.s3_write_prefix, "/")
    error_message = "s3_write_prefix must be non-empty and end with '/'."
  }
}

variable "api_name" {
  description = "Name segment used for the API task role"
  type        = string
  default     = "api"
}

variable "worker_name" {
  description = "Name segment used for the worker task role"
  type        = string
  default     = "worker"
}
