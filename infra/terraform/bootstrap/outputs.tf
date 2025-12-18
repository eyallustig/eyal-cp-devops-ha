output "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = module.state_backend.state_bucket_name
}

output "lock_table_name" {
  description = "Name of the DynamoDB lock table for state locking"
  value       = module.state_backend.lock_table_name
}
