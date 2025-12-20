locals {
  worker_image = "${module.ecr_worker.repository_url}:${var.worker_image_tag}"

  worker_env = {
    AWS_REGION      = var.region
    AWS_MAX_RETRIES = tostring(var.aws_max_retries)
    LOG_LEVEL       = var.log_level

    SQS_QUEUE_URL          = data.terraform_remote_state.data_config.outputs.emails_queue_url
    S3_BUCKET              = data.terraform_remote_state.data_config.outputs.payload_bucket_name
    APP_ENV                = var.environment
    POLL_WAIT_SECONDS      = tostring(var.worker_poll_wait_seconds)
    SLEEP_ON_EMPTY_SECONDS = tostring(var.worker_sleep_on_empty_seconds)
    VISIBILITY_TIMEOUT     = tostring(var.worker_visibility_timeout)
    MAX_MESSAGES           = tostring(var.worker_max_messages)
  }
}

module "worker_service" {
  source = "../../../../modules/ecs_fargate_service"

  name_prefix  = local.name_prefix
  service_name = "worker"

  cluster_arn        = module.ecs_cluster.cluster_arn
  subnet_ids         = data.aws_subnets.default.ids
  security_group_ids = [aws_security_group.ecs_worker_tasks.id]
  assign_public_ip   = var.assign_public_ip
  desired_count      = var.worker_desired_count

  cpu    = 256
  memory = 512

  container_image = local.worker_image
  container_port  = null
  environment     = local.worker_env

  execution_role_arn = module.iam_roles.execution_role_arn
  task_role_arn      = module.iam_roles.worker_task_role_arn

  create_log_group   = true
  log_retention_days = var.log_retention_days

  enable_container_healthcheck = true
  healthcheck_command = [
    "CMD-SHELL",
    "python -c \"import os,time,sys; p='/tmp/worker_heartbeat'; sys.exit(0) if os.path.exists(p) and time.time()-os.path.getmtime(p) < 90 else sys.exit(1)\"",
  ]
  healthcheck_interval     = 30
  healthcheck_timeout      = 5
  healthcheck_retries      = 3
  healthcheck_start_period = 20

  target_group_arn = null

  tags = local.tags
}
