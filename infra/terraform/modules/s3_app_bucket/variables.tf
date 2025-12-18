variable "bucket_name" {
  description = "Full name of the S3 bucket to create"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}

variable "force_destroy" {
  description = "If true, delete all objects when destroying the bucket"
  type        = bool
  default     = false
}

variable "noncurrent_version_expiration_days" {
  description = "Days to retain noncurrent object versions"
  type        = number
  default     = 30

  validation {
    condition     = var.noncurrent_version_expiration_days >= 1
    error_message = "noncurrent_version_expiration_days must be >= 1."
  }
}

variable "object_expiration_days" {
  description = "Days to retain current objects"
  type        = number
  default     = 30

  validation {
    condition     = var.object_expiration_days >= 1
    error_message = "object_expiration_days must be >= 1."
  }
}

variable "enforce_tls" {
  description = "Enforce TLS-only bucket access via policy"
  type        = bool
  default     = true
}
