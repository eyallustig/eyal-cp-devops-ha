variable "project" {
  description = "Project name"
  type        = string
  default     = "eyal-cp-devops-ha"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "shared"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "owner" {
  description = "Owner tag"
  type        = string
  default     = null
}

variable "backend_prefix" {
  description = "Prefix for backend resources"
  type        = string
  default     = "eyal-cp-devops-ha"
}
