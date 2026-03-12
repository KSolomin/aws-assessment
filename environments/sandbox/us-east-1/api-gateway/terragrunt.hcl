include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "../../../../modules/api-gateway"
}

dependency "greeter" {
  config_path = "../greeter"
}

dependency "dispatcher" {
  config_path = "../dispatcher"
}

dependency "cognito" {
  config_path = "../cognito"
}

inputs = {
  cognito_user_pool_id  = dependency.cognito.outputs.user_pool_id
  cognito_app_client_id = dependency.cognito.outputs.user_pool_client_id
  lambda_greeter_arn    = dependency.greeter.outputs.lambda_greeter_arn
  lambda_dispatcher_arn = dependency.dispatcher.outputs.lambda_dispatcher_arn
  lambda_greeter_name   = "greeter"
}