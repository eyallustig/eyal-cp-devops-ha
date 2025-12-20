module "github_oidc_provider" {
  source = "../modules/github_oidc_provider"
  tags   = local.tags
}

module "github_actions_ci_role" {
  source = "../modules/github_actions_ci_role"

  name_prefix       = local.name_prefix
  oidc_provider_arn = module.github_oidc_provider.oidc_provider_arn
  github_owner      = "eyallustig"
  github_repo       = "eyal-cp-devops-ha"
  allowed_ref       = "refs/heads/main"
  tags              = local.tags
}
