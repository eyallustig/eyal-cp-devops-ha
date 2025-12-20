module "payload_bucket" {
  source = "../../../../modules/s3_app_bucket"

  bucket_name = local.payload_bucket_name
  tags        = local.tags

  force_destroy                      = var.payload_force_destroy
  noncurrent_version_expiration_days = var.payload_noncurrent_version_expiration_days
  object_expiration_days             = var.payload_object_expiration_days

  enforce_tls = true
}
