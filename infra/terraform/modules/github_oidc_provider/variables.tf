variable "tags" {
  description = "Tags applied to the OIDC provider."
  type        = map(string)
  default     = {}
}

variable "url" {
  description = "OIDC issuer URL."
  type        = string
  default     = "https://token.actions.githubusercontent.com"
}

variable "client_id_list" {
  description = "OIDC client IDs (audiences)."
  type        = list(string)
  default     = ["sts.amazonaws.com"]
}

variable "thumbprint_list" {
  description = "OIDC provider certificate thumbprints."
  type        = list(string)
  default     = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}
