data "archive_file" "lambda" {
    type = "zip"
    source_file = "${path.module}/src/dispatcher.py"
    output_path = "${path.module}/src/dispatcher.zip"
}

data "aws_iam_role" "lambda_role" {
  name = "${var.function_name}-lambda-role"
}

resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = data.aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "dispatcher" {
  function_name = var.function_name

  role    = data.aws_iam_role.lambda_role.arn
  handler = var.handler
  runtime = var.runtime

  filename         = "src/dispatcher.zip"
  source_code_hash = filebase64sha256(data.archive_file.lambda.output_path)

  environment {
    variables = var.environment_variables
  }
}
