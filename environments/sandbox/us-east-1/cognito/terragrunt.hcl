include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "../../../../modules/cognito"
}

inputs = {
  user_pool_name        = "aws-assessment-user-pool"
  user_pool_client_name = "aws-assessment-user-pool-client"
}
