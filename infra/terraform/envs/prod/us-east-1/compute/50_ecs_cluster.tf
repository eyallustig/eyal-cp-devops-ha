module "ecs_cluster" {
  source = "../../../../modules/ecs_cluster"

  name = "${local.name_prefix}-cluster"
  tags = local.tags

  # keep disabled to stay free-tier friendly
  enable_container_insights = false
}
