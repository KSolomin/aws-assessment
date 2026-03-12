variable "region" {
  default = "us-east-1"
}

variable "cognito_user_pool_id" {
  description = "Cognito User Pool ID in us-east-1"
  type        = string
}

variable "cognito_app_client_id" {
  description = "Cognito User Pool App Client ID (audience for JWTs)"
  type        = string
}

variable "lambda_greeter_arn" {
  description = "Lambda ARN for /greet route"
  type        = string
}

variable "lambda_greeter_name" {
  description = "Lambda name for /greet route"
  type        = string
}

variable "lambda_dispatcher_arn" {
  description = "Lambda ARN for /dispatch route"
  type        = string
}
