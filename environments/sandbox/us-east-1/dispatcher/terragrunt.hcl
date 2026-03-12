include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "../../../../modules/lambda/dispatcher"
}

dependency "fargate" {
  config_path = "../fargate"
}

inputs = {
  function_name               = "dispatcher"
  handler                     = "dispatcher.handler"
  fargate_cluster_id          = dependency.fargate.outputs.cluster_id
  fargate_subnet_id           = ""
  fargate_service_name        = dependency.fargate.outputs.service_name
  fargate_task_definition_arn = dependency.fargate.outputs.task_definition_arn
  create_role                 = true
}
