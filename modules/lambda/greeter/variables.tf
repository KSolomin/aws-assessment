variable "function_name" {
  type        = string
  description = "Lambda function name"
}

variable "runtime" {
  type        = string
  default     = "python3.13"
}

variable "handler" {
  type        = string
  description = "Handler entrypoint (e.g. greeter.lambda_handler)"
  default     = "greeter.lambda_handler"
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}

variable "dynamodb_table_name" {
  description = "Optional DynamoDB table name that the function may put items into. If empty, no write policy is added."
  type        = string
  default     = ""
}

variable "create_role" {
  type        = bool
  default     = false
  description = "Whether to create an IAM role for the Lambda function"
}
