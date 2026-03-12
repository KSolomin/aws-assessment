generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite"

  contents = <<EOF
terraform {
  backend "s3" {
    region = "us-east-1"
    bucket = "aws-assessment"
    key    = "aws-assessment/${path_relative_to_include()}/terraform.tfstate"
  }
}
EOF
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"

  contents = <<EOF
provider "aws" {
  region = "${split("/", path_relative_to_include())[0]}"
}
EOF
}
