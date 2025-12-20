output "oidc_provider_arn" {
  description = "OIDC provider ARN."
  value       = aws_iam_openid_connect_provider.this.arn
}

output "oidc_provider_url" {
  description = "OIDC provider URL."
  value       = aws_iam_openid_connect_provider.this.url
}
