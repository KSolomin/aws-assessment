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
  description = "Handler entrypoint (e.g. dispatcher.lambda_handler)"
  default     = "dispatcher.lambda_handler"
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}

variable "create_role" {
  type        = bool
  default     = false
  description = "Whether to create an IAM role for the Lambda function"
}
