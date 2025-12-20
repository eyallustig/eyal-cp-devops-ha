provider "aws" {
  region = local.region
}

module "state_backend" {
  source = "../modules/state_backend"

  backend_prefix = local.backend_prefix
  region         = local.region
  tags           = local.tags
}
