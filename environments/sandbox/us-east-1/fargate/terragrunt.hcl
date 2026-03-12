include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "../../../../modules/fargate"
}

inputs = {
  vpc_id           = ""
  public_subnet_id = ""
  cluster_name     = "dispatcher-cluster"
  service_name     = "dispatcher-service"
  sns_topic_arn    = ""
}