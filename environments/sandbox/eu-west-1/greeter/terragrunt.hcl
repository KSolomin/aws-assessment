include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "../../../../modules/lambda/greeter"
}

dependency "dynamodb" {
  config_path = "../dynamodb"
}

inputs = {
  function_name = "greeter"
  handler       = "greeter.handler"
  environment_variables = {
    TABLE_NAME    = "GreetingLogs"
    SNS_TOPIC_ARN = ""
  }
  dynamodb_table_name = dependency.dynamodb.outputs.table_name
}
