locals {
  project        = var.project
  environment    = var.environment
  region         = var.region
  backend_prefix = var.backend_prefix
  name_prefix    = var.backend_prefix

  tags = merge(
    {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.owner != null ? { Owner = var.owner } : {}
  )
}
