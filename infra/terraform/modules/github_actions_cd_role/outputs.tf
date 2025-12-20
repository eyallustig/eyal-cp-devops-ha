output "role_arn" {
  description = "IAM role ARN for GitHub Actions CD."
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "IAM role name for GitHub Actions CD."
  value       = aws_iam_role.this.name
}

output "assume_role_policy_json" {
  description = "Assume role policy JSON for the CD role."
  value       = local.assume_role_policy
}
