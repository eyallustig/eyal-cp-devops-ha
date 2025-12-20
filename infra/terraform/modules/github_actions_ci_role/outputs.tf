output "role_arn" {
  description = "IAM role ARN for GitHub Actions CI."
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "IAM role name for GitHub Actions CI."
  value       = aws_iam_role.this.name
}

output "assume_role_policy_json" {
  description = "Assume role policy JSON for the CI role."
  value       = local.assume_role_policy
}

output "policy_name" {
  description = "Inline policy name for ECR push permissions."
  value       = aws_iam_role_policy.ecr_push.name
}
