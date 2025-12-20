module "token_parameter" {
  source = "../../../../modules/ssm_secure_parameter"

  name        = local.token_param_name
  description = var.token_parameter_description
  tags        = local.tags

  placeholder_value = var.token_placeholder_value
  tier              = "Standard"
}
