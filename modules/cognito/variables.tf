variable "user_pool_name" {
  type        = string
  description = "Name of the Cognito User Pool"
}

variable "user_pool_client_name" {
  type        = string
  description = "Name of the Cognito User Pool Client"
}

variable "username_attributes" {
  type        = list(string)
  default     = ["email"]
}

variable "auto_verified_attributes" {
  type        = list(string)
  default     = ["email"]
}

variable "generate_secret" {
  type    = bool
  default = true
}

variable "enable_oauth_flows" {
  type    = bool
  default = true
}

variable "allowed_oauth_flows" {
  type    = list(string)
  default = ["code"]
}

variable "allowed_oauth_scopes" {
  type    = list(string)
  default = ["openid", "email", "profile"]
}

variable "explicit_auth_flows" {
  type = list(string)
  default = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}
