resource "aws_ecs_cluster" "this" {
  name = var.name

  dynamic "setting" {
    for_each = var.enable_container_insights ? [1] : []
    content {
      name  = "containerInsights"
      value = "enabled"
    }
  }

  tags = var.tags
}
