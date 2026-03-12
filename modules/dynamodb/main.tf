resource "aws_dynamodb_table" "this" {
  name         = var.name
  hash_key     = var.hash_key

  attribute {
    name = var.hash_key
    type = var.hash_key_type
  }

  billing_mode   = var.billing_mode
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity
}

# optional IAM policy allowing a specific cross‑account (or same‑account) role to PutItem
resource "aws_iam_policy" "writer" {
  count = var.deploy_writer_policy ? 1 : 0
  name        = "${var.name}-allow-putitem"
  description = "Allow the greeter lambda role to put items in the table"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowPutItem"
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:UpdateItem"
        ]
        Resource = aws_dynamodb_table.this.arn
      }
    ]
  })
}
