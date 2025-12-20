variable "name_prefix" {
  description = "Prefix used for naming ECS resources."
  type        = string
}

variable "service_name" {
  description = "Service name used for ECS resources."
  type        = string
}

variable "cluster_arn" {
  description = "ECS cluster ARN."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the service network configuration."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs for the service network configuration."
  type        = list(string)
}

variable "assign_public_ip" {
  description = "Assign a public IP to the service ENI."
  type        = bool
}

variable "desired_count" {
  description = "Desired task count."
  type        = number
}

variable "cpu" {
  description = "Task CPU units."
  type        = number
}

variable "memory" {
  description = "Task memory (MiB)."
  type        = number
}

variable "container_image" {
  description = "Container image with tag (e.g., repo-url:sha7)."
  type        = string
}

variable "execution_role_arn" {
  description = "ECS task execution role ARN."
  type        = string
}

variable "task_role_arn" {
  description = "ECS task role ARN."
  type        = string
}

variable "tags" {
  description = "Tags applied to created resources."
  type        = map(string)
  default     = {}
}

variable "container_port" {
  description = "Container port exposed by the task."
  type        = number
  default     = null
}

variable "environment" {
  description = "Environment variables for the container."
  type        = map(string)
  default     = {}
}

variable "create_log_group" {
  description = "Whether to create the CloudWatch log group."
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days."
  type        = number
  default     = 3
}

variable "deployment_minimum_healthy_percent" {
  description = "Minimum healthy percent during a deployment."
  type        = number
  default     = 100

  validation {
    condition     = var.deployment_minimum_healthy_percent >= 0 && var.deployment_minimum_healthy_percent <= 100
    error_message = "deployment_minimum_healthy_percent must be between 0 and 100."
  }
}

variable "deployment_maximum_percent" {
  description = "Maximum percent of tasks during a deployment."
  type        = number
  default     = 200

  validation {
    condition = (
      var.deployment_maximum_percent >= 100 &&
      var.deployment_maximum_percent <= 200
    )
    error_message = "deployment_maximum_percent must be between 100 and 200."
  }
}

variable "enable_container_healthcheck" {
  description = "Enable container healthcheck."
  type        = bool
  default     = false
}

variable "healthcheck_command" {
  description = "Container healthcheck command list."
  type        = list(string)
  default     = []
}

variable "healthcheck_interval" {
  description = "Container healthcheck interval (seconds)."
  type        = number
  default     = 30
}

variable "healthcheck_retries" {
  description = "Container healthcheck retries."
  type        = number
  default     = 3
}

variable "healthcheck_timeout" {
  description = "Container healthcheck timeout (seconds)."
  type        = number
  default     = 5
}

variable "healthcheck_start_period" {
  description = "Container healthcheck start period (seconds)."
  type        = number
  default     = 10
}

variable "target_group_arn" {
  description = "Target group ARN for optional load balancer attachment."
  type        = string
  default     = null
}

variable "health_check_grace_period_seconds" {
  description = "Health check grace period in seconds (only for load balancer)."
  type        = number
  default     = 60
}
