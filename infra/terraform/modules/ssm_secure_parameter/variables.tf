variable "name" {
  description = "Full SSM parameter name (must start with /)"
  type        = string

  validation {
    condition     = can(regex("^/", var.name))
    error_message = "SSM parameter name must start with '/' (path-style)."
  }
}

variable "description" {
  description = "Description for the SSM parameter"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the parameter"
  type        = map(string)
}

variable "placeholder_value" {
  description = "Placeholder value; real secret must be set manually out-of-band"
  type        = string
  default     = "CHANGEME"
  sensitive   = true
}

variable "tier" {
  description = "SSM parameter tier"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Advanced", "Intelligent-Tiering"], var.tier)
    error_message = "tier must be one of Standard, Advanced, Intelligent-Tiering."
  }
}
