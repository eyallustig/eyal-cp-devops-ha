variable "backend_prefix" {
  description = "Prefix for backend resources"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "noncurrent_version_expiration_days" {
  description = "Days to retain noncurrent object versions"
  type        = number
  default     = 30
}

variable "dynamodb_read_capacity" {
  description = "Provisioned read capacity for DynamoDB lock table"
  type        = number
  default     = 5
}

variable "dynamodb_write_capacity" {
  description = "Provisioned write capacity for DynamoDB lock table"
  type        = number
  default     = 5
}

variable "force_destroy" {
  description = "If true, allow Terraform to delete all objects in the state bucket when destroying it."
  type        = bool
  default     = false
}
