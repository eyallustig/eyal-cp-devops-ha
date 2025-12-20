locals {
  api_image = "${module.ecr_api.repository_url}:${var.api_image_tag}"

  api_env = {
    AWS_REGION      = var.region
    AWS_MAX_RETRIES = tostring(var.aws_max_retries)
    LOG_LEVEL       = var.log_level

    SSM_TOKEN_PARAM = data.terraform_remote_state.data_config.outputs.token_parameter_name
    SQS_QUEUE_URL   = data.terraform_remote_state.data_config.outputs.emails_queue_url
  }
}

module "api_service" {
  source = "../../../../modules/ecs_fargate_service"

  name_prefix  = local.name_prefix
  service_name = "api"

  cluster_arn        = module.ecs_cluster.cluster_arn
  subnet_ids         = data.aws_subnets.default.ids
  security_group_ids = [aws_security_group.ecs_api_tasks.id]
  assign_public_ip   = var.assign_public_ip
  desired_count      = var.api_desired_count

  cpu    = 256
  memory = 512

  container_image = local.api_image
  container_port  = 8000
  environment     = local.api_env

  execution_role_arn = module.iam_roles.execution_role_arn
  task_role_arn      = module.iam_roles.api_task_role_arn

  create_log_group   = true
  log_retention_days = var.log_retention_days

  enable_container_healthcheck = true
  healthcheck_command = [
    "CMD-SHELL",
    "python -c \"import urllib.request; urllib.request.urlopen('http://localhost:8000/healthz')\"",
  ]
  healthcheck_interval     = 30
  healthcheck_timeout      = 5
  healthcheck_retries      = 3
  healthcheck_start_period = 20

  target_group_arn = module.alb.target_group_arn

  tags = local.tags
}
