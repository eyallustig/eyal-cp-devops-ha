output "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = module.state_backend.state_bucket_name
}

output "lock_table_name" {
  description = "Name of the DynamoDB lock table for state locking"
  value       = module.state_backend.lock_table_name
}

output "github_oidc_provider_arn" {
  description = "GitHub Actions OIDC provider ARN."
  value       = module.github_oidc_provider.oidc_provider_arn
}

output "github_actions_ci_role_arn" {
  description = "IAM role ARN for GitHub Actions CI."
  value       = module.github_actions_ci_role.role_arn
}

output "github_actions_ci_role_name" {
  description = "IAM role name for GitHub Actions CI."
  value       = module.github_actions_ci_role.role_name
}

output "github_actions_cd_role_arn" {
  description = "IAM role ARN for GitHub Actions CD."
  value       = module.github_actions_cd_role.role_arn
}

output "github_actions_cd_role_name" {
  description = "IAM role name for GitHub Actions CD."
  value       = module.github_actions_cd_role.role_name
}
