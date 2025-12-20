variable "name" {
  description = "ECS cluster name."
  type        = string
}

variable "tags" {
  description = "Tags applied to the cluster."
  type        = map(string)
  default     = {}
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights (can cost money; keep default false)."
  type        = bool
  default     = false
}
