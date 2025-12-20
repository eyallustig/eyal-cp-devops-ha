module "github_actions_cd_role" {
  source            = "../modules/github_actions_cd_role"
  oidc_provider_arn = module.github_oidc_provider.oidc_provider_arn

  name_prefix  = local.name_prefix
  github_owner = "eyallustig"
  github_repo  = "eyal-cp-devops-ha"
  allowed_ref  = "refs/heads/main"

  tags = local.tags
}
