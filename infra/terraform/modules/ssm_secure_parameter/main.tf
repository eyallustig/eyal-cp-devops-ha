resource "aws_ssm_parameter" "this" {
  name        = var.name
  description = var.description
  type        = "SecureString"
  value       = var.placeholder_value
  tier        = var.tier
  tags        = var.tags

  lifecycle {
    ignore_changes = [value]
  }
}
