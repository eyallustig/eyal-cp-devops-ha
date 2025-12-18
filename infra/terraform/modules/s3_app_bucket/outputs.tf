output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.payload.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.payload.arn
}

output "bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.payload.id
}

output "bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = aws_s3_bucket.payload.bucket_regional_domain_name
}
