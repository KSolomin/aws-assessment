resource "aws_cognito_user_pool" "this" {
  name = var.user_pool_name

  username_attributes      = var.username_attributes
  auto_verified_attributes = var.auto_verified_attributes

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = true
  }

  mfa_configuration = "OFF"
}

resource "aws_cognito_user_pool_client" "this" {
  name         = var.user_pool_client_name
  user_pool_id = aws_cognito_user_pool.this.id

  generate_secret = var.generate_secret

  allowed_oauth_flows                  = var.allowed_oauth_flows
  allowed_oauth_scopes                 = var.allowed_oauth_scopes
  allowed_oauth_flows_user_pool_client = var.enable_oauth_flows

  callback_urls = ["https://app.example.com/callback"]
  logout_urls   = ["https://app.example.com/logout"]

  supported_identity_providers = ["COGNITO"]

  explicit_auth_flows = var.explicit_auth_flows
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "assessment-domain"
  user_pool_id = aws_cognito_user_pool.this.id
}