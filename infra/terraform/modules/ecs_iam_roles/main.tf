data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name               = "${var.name_prefix}-ecs-task-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_managed" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "api_task" {
  statement {
    actions   = ["ssm:GetParameter"]
    resources = [var.ssm_parameter_arn]
  }

  statement {
    actions   = ["sqs:SendMessage"]
    resources = [var.sqs_queue_arn]
  }
}

resource "aws_iam_role" "api_task" {
  name               = "${var.name_prefix}-${var.api_name}-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "api_task" {
  name   = "${var.name_prefix}-${var.api_name}-task"
  role   = aws_iam_role.api_task.name
  policy = data.aws_iam_policy_document.api_task.json
}

data "aws_iam_policy_document" "worker_task" {
  statement {
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ChangeMessageVisibility",
    ]
    resources = [var.sqs_queue_arn]
  }

  statement {
    actions = [
      "s3:PutObject",
      "s3:AbortMultipartUpload",
    ]
    resources = ["${var.s3_bucket_arn}/${var.s3_write_prefix}*"]
  }
}

resource "aws_iam_role" "worker_task" {
  name               = "${var.name_prefix}-${var.worker_name}-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "worker_task" {
  name   = "${var.name_prefix}-${var.worker_name}-task"
  role   = aws_iam_role.worker_task.name
  policy = data.aws_iam_policy_document.worker_task.json
}
