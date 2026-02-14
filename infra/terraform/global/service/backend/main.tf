variable "env" {
  type = string
}

variable "table_name" {
  type = string
}

variable "table_arn" {
  type = string
}

resource "aws_iam_policy" "dynamodb_policy" {
  name        = "dynamodb_access_lambda-${var.env}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:UpdateItem"
        ]
        Resource = var.table_arn
      }
    ]
  })
}

resource "aws_iam_role" "lambda_role" {
  name = "snack_lambda_role-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_dynamo" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.dynamodb_policy.arn
}

resource "aws_lambda_function" "api_backend" {
  filename      = "backend.zip"
  function_name = "snack_backend-${var.env}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "main"
  runtime       = "provided.al2023"
  timeout       = 15

  environment {
    variables = {
      DYNAMODB_TABLE = var.table_name
    }
  }

  lifecycle {
    ignore_changes = [filename]
  }
}

resource "aws_lambda_function_url" "api_url" {
  function_name      = aws_lambda_function.api_backend.function_name
  authorization_type = "NONE"

  cors {
    allow_origins = ["*"]
    allow_methods = ["GET"]
  }
}
