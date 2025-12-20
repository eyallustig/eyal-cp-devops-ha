module "iam_roles" {
  source = "../../../../modules/ecs_iam_roles"

  name_prefix = local.name_prefix
  tags        = local.tags

  sqs_queue_arn     = data.terraform_remote_state.data_config.outputs.emails_queue_arn
  ssm_parameter_arn = data.terraform_remote_state.data_config.outputs.token_parameter_arn
  s3_bucket_arn     = data.terraform_remote_state.data_config.outputs.payload_bucket_arn
  s3_write_prefix   = local.s3_write_prefix

  # Optional (keep defaults), can be omitted:
  # api_name    = "api"
  # worker_name = "worker"
}
