resource "aws_security_group" "ecs_worker_tasks" {
  name        = "${local.name_prefix}-ecs-worker-tasks"
  description = "Security group for ECS tasks (worker)"
  vpc_id      = data.aws_vpc.default.id

  # No ingress for worker tasks
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_security_group" "ecs_api_tasks" {
  name        = "${local.name_prefix}-ecs-api-tasks"
  description = "Security group for ECS API tasks (ingress only from ALB)"
  vpc_id      = data.aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_security_group_rule" "api_ingress_from_alb" {
  type                     = "ingress"
  security_group_id        = aws_security_group.ecs_api_tasks.id
  from_port                = 8000
  to_port                  = 8000
  protocol                 = "tcp"
  source_security_group_id = module.alb.alb_security_group_id
  description              = "Allow ALB to reach API tasks on port 8000"
}
