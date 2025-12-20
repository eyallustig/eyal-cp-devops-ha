# ALB is for the API service only (worker has no ALB).
module "alb" {
  source = "../../../../modules/alb_http"

  name_prefix       = local.name_prefix
  vpc_id            = data.aws_vpc.default.id
  subnet_ids        = data.aws_subnets.default.ids
  target_port       = 8000
  health_check_path = "/healthz"
  tags              = local.tags
}
