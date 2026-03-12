data "archive_file" "lambda" {
    type = "zip"
    source_file = "${path.module}/src/greeter.py"
    output_path = "${path.module}/src/greeter.zip"
}

data "aws_iam_role" "lambda_role" {
  name = "${var.function_name}-lambda-role"
}

resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = data.aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# optional inline policy granting PutItem/UpdateItem access to a specific DynamoDB table
resource "aws_iam_role_policy" "dynamodb_write" {
  count = var.dynamodb_table_name != "" ? 1 : 0

  name   = "${var.function_name}-dynamodb-write"
  role   = data.aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowTableWrites"
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:BatchWriteItem"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/${var.dynamodb_table_name}"
      }
    ]
  })
}

resource "aws_lambda_function" "greeter" {
  function_name = var.function_name

  role    = data.aws_iam_role.lambda_role.arn
  handler = var.handler
  runtime = var.runtime

  filename         = "src/greeter.zip"
  source_code_hash = filebase64sha256(data.archive_file.lambda.output_path)

  environment {
    variables = var.environment_variables
  }
}
