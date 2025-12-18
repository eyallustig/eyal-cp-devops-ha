provider "aws" {
  region = var.region
}

module "state_backend" {
  source = "../modules/state_backend"

  backend_prefix = var.backend_prefix
  region         = var.region
  tags = merge(
    {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.owner != null ? { Owner = var.owner } : {}
  )
}
