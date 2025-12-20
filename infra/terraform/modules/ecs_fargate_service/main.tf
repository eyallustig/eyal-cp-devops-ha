data "aws_region" "current" {}

locals {
  log_group_name = "/${var.name_prefix}/${var.service_name}"

  environment = [
    for key in sort(keys(var.environment)) : {
      name  = key
      value = var.environment[key]
    }
  ]

  container_definition = merge(
    {
      name        = var.service_name
      image       = var.container_image
      essential   = true
      environment = local.environment
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = local.log_group_name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = var.service_name
        }
      }
    },
    var.container_port != null ? {
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
    } : {},
    var.enable_container_healthcheck ? {
      healthCheck = {
        command     = var.healthcheck_command
        interval    = var.healthcheck_interval
        retries     = var.healthcheck_retries
        timeout     = var.healthcheck_timeout
        startPeriod = var.healthcheck_start_period
      }
    } : {}
  )
}

resource "aws_cloudwatch_log_group" "this" {
  count = var.create_log_group ? 1 : 0

  name              = local.log_group_name
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.name_prefix}-${var.service_name}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = tostring(var.cpu)
  memory                   = tostring(var.memory)
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  container_definitions    = jsonencode([local.container_definition])
  tags                     = var.tags
}

resource "aws_ecs_service" "this" {
  name            = "${var.name_prefix}-${var.service_name}"
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  enable_ecs_managed_tags = true
  propagate_tags          = "SERVICE"

  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = var.assign_public_ip
  }

  dynamic "load_balancer" {
    for_each = var.target_group_arn != null ? [1] : []

    content {
      target_group_arn = var.target_group_arn
      container_name   = var.service_name
      container_port   = var.container_port
    }
  }

  health_check_grace_period_seconds = var.target_group_arn != null ? var.health_check_grace_period_seconds : null

  tags = var.tags
}
