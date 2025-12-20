# Example usage:
# module "github_oidc" {
#   source = "../github_oidc_provider"
# }
#
# module "github_ci" {
#   source            = "../github_actions_ci_role"
#   name_prefix       = "example"
#   oidc_provider_arn = module.github_oidc.oidc_provider_arn
# }

locals {
  role_name = "${var.name_prefix}-github-actions-ci"
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

  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage",
          "ecr:BatchGetImage",
          "ecr:DescribeRepositories",
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = "ecr:GetAuthorizationToken"
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

resource "aws_iam_role_policy" "ecr_push" {
  name   = "${local.role_name}-ecr-push"
  role   = aws_iam_role.this.name
  policy = local.policy_document
}
