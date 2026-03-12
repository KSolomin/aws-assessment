include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "../../../../modules/dynamodb"
}

inputs = {
  name     = "GreetingLogs"
  hash_key = "id"
}