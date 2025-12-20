locals {
  role_name = "${var.name_prefix}-github-actions-cd"
  sub_claim = "repo:${var.github_owner}/${var.github_repo}:ref:${var.allowed_ref}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRoleWithWebIdentity"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = local.sub_claim
          }
        }
      }
    ]
  })

  state_backend_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:UpdateItem",
        ]
        Resource = "*"
      }
    ]
  })

  ecs_deploy_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeServices",
          "ecs:UpdateService",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition",
          "ecs:ListTasks",
          "ecs:DescribeTasks",
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
        ]
        Resource = "*"
      }
    ]
  })

  pass_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = "*"
      }
    ]
  })

  describe_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "elasticloadbalancing:Describe*",
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "this" {
  name               = local.role_name
  assume_role_policy = local.assume_role_policy
  tags               = var.tags
}

resource "aws_iam_role_policy" "state_backend" {
  name   = "${local.role_name}-state-backend"
  role   = aws_iam_role.this.name
  policy = local.state_backend_policy
}

resource "aws_iam_role_policy" "ecs_deploy" {
  name   = "${local.role_name}-ecs-deploy"
  role   = aws_iam_role.this.name
  policy = local.ecs_deploy_policy
}

resource "aws_iam_role_policy" "pass_role" {
  name   = "${local.role_name}-pass-role"
  role   = aws_iam_role.this.name
  policy = local.pass_role_policy
}

resource "aws_iam_role_policy" "describe" {
  name   = "${local.role_name}-describe"
  role   = aws_iam_role.this.name
  policy = local.describe_policy
}
