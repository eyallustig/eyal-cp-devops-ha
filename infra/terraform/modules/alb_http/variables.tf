variable "name_prefix" {
  description = "Prefix used for naming ALB resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the ALB and target group."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the ALB."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "subnet_ids must contain at least one subnet ID."
  }
}

variable "target_port" {
  description = "Target port for the API service."
  type        = number
  default     = 8000

  validation {
    condition     = var.target_port >= 1 && var.target_port <= 65535
    error_message = "target_port must be between 1 and 65535."
  }
}

variable "health_check_path" {
  description = "HTTP health check path for the target group."
  type        = string
  default     = "/healthz"

  validation {
    condition     = startswith(var.health_check_path, "/")
    error_message = "health_check_path must start with '/'."
  }
}

variable "tags" {
  description = "Tags applied to ALB resources."
  type        = map(string)
  default     = {}
}
