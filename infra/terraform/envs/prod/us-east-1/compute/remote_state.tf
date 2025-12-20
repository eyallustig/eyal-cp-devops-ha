data "terraform_remote_state" "data_config" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket
    key    = var.data_config_state_key
    region = var.region

  }
}
