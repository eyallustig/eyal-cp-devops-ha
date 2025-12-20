module "ecr_api" {
  source = "../../../../modules/ecr_repository"

  name = local.ecr_api_repo_name
  tags = local.tags

  image_tag_mutability       = "IMMUTABLE"
  scan_on_push               = true
  encryption_type            = "AES256"
  force_delete               = var.ecr_force_delete
  max_tagged_images          = var.ecr_max_tagged_images
  expire_untagged_after_days = var.ecr_expire_untagged_after_days
}

module "ecr_worker" {
  source = "../../../../modules/ecr_repository"

  name = local.ecr_worker_repo_name
  tags = local.tags

  image_tag_mutability       = "IMMUTABLE"
  scan_on_push               = true
  encryption_type            = "AES256"
  force_delete               = var.ecr_force_delete
  max_tagged_images          = var.ecr_max_tagged_images
  expire_untagged_after_days = var.ecr_expire_untagged_after_days
}
