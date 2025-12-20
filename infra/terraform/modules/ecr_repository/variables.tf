variable "name" {
  description = "ECR repository name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the repository"
  type        = map(string)
}

variable "image_tag_mutability" {
  description = "Tag mutability setting (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Enable image scan on push"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "ECR encryption type (AES256 or KMS)"
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "encryption_type must be AES256 or KMS."
  }
}

variable "force_delete" {
  description = "Allow deleting the repo even if images exist"
  type        = bool
  default     = false
}

variable "max_tagged_images" {
  description = "Keep only the last N tagged images"
  type        = number
  default     = 5

  validation {
    condition     = var.max_tagged_images >= 1
    error_message = "max_tagged_images must be >= 1."
  }
}

variable "expire_untagged_after_days" {
  description = "Expire untagged images older than N days"
  type        = number
  default     = 3

  validation {
    condition     = var.expire_untagged_after_days >= 1
    error_message = "expire_untagged_after_days must be >= 1."
  }
}
