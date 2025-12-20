variable "name_prefix" {
  description = "Prefix used for naming the GitHub Actions CI role."
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the GitHub Actions OIDC provider."
  type        = string
}

variable "github_owner" {
  description = "GitHub organization or user."
  type        = string
  default     = "eyallustig"
}

variable "github_repo" {
  description = "GitHub repository name."
  type        = string
  default     = "eyal-cp-devops-ha"
}

variable "allowed_ref" {
  description = "Git reference allowed to assume the role."
  type        = string
  default     = "refs/heads/main"
}

variable "tags" {
  description = "Tags applied to the IAM role."
  type        = map(string)
  default     = {}
}
