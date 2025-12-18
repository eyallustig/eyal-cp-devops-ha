output "emails_queue_url" {
  description = "Main emails SQS queue URL"
  value       = module.emails_sqs.queue_url
}

output "emails_queue_arn" {
  description = "Main emails SQS queue ARN"
  value       = module.emails_sqs.queue_arn
}

output "emails_dlq_url" {
  description = "Emails SQS DLQ URL"
  value       = module.emails_sqs.dlq_url
}

output "emails_dlq_arn" {
  description = "Emails SQS DLQ ARN"
  value       = module.emails_sqs.dlq_arn
}

output "payload_bucket_name" {
  description = "Payload S3 bucket name"
  value       = module.payload_bucket.bucket_name
}

output "payload_bucket_arn" {
  description = "Payload S3 bucket ARN"
  value       = module.payload_bucket.bucket_arn
}

output "token_parameter_name" {
  description = "SSM SecureString parameter name for the application token"
  value       = module.token_parameter.parameter_name
}

output "token_parameter_arn" {
  description = "SSM SecureString parameter ARN for the application token"
  value       = module.token_parameter.parameter_arn
}
