resource "aws_apigatewayv2_api" "http_api" {
  name          = "example-http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_authorizer" "cognito_authorizer" {
  name             = "cognito-authorizer"
  api_id           = aws_apigatewayv2_api.http_api.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    # API Gateway expects the "aud" claim to match an app client ID, not the
    # user pool id.  The previous configuration mistakenly passed the pool id,
    # which made every token fail validation and produced the
    # `{\"message\":\"Unauthorized\"}` response.
    audience = [var.cognito_app_client_id]
    issuer   = "https://cognito-idp.${var.region}.amazonaws.com/${var.cognito_user_pool_id}"
  }
}

resource "aws_apigatewayv2_integration" "greet_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.lambda_greeter_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "dispatch_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.lambda_dispatcher_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "greet_route" {
  api_id             = aws_apigatewayv2_api.http_api.id
  route_key          = "GET /greet"
  target             = "integrations/${aws_apigatewayv2_integration.greet_integration.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_authorizer.id
}

resource "aws_apigatewayv2_route" "dispatch_route" {
  api_id             = aws_apigatewayv2_api.http_api.id
  route_key          = "POST /dispatch"
  target             = "integrations/${aws_apigatewayv2_integration.dispatch_integration.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_authorizer.id
}

resource "aws_lambda_permission" "allow_apigw_greet" {
  statement_id  = "AllowAPIGatewayInvokeGreet"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_greeter_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "allow_apigw_dispatch" {
  statement_id  = "AllowAPIGatewayInvokeDispatch"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_dispatcher_arn
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}
