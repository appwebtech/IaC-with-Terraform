# DynamoDB and Lambda Function
resource "aws_dynamodb_table" "counter_table" {
  name         = var.web-page_counter
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "page_id"
  attribute {
    name = "page_id"
    type = "S"
  }
}

# DynamoDB Policy
resource "aws_iam_policy" "dynamodb_policy" {
  name        = "DynamoDBPolicy"
  description = "IAM policy for DynamoDB access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "dynamodb:UpdateItem",
        "dynamodb:PutItem",
        "dynamodb:GetItem"
      ],
      Effect   = "Allow",
      Resource = aws_dynamodb_table.counter_table.arn
    }]
  })
}

# DynamoDB Role
resource "aws_iam_role" "counter_lambda_role" {
  name = var.lambda_role

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "dynamodb_attachment" {
  policy_arn = aws_iam_policy.dynamodb_policy.arn
  role       = aws_iam_role.counter_lambda_role.name
}


resource "aws_iam_policy_attachment" "counter_lambda_policy_attachment" {
  name       = var.lambda_attachment
  policy_arn = aws_iam_policy.dynamodb_policy.arn
  roles      = [aws_iam_role.counter_lambda_role.name]
}

# Lambda
resource "aws_lambda_function" "counter_lambda" {
  filename      = "counter_lambda.zip"
  function_name = "website_counter_lambda"
  role          = aws_iam_role.counter_lambda_role.arn
  handler       = "lambda_function.handler"
  runtime       = "python3.8"
  timeout       = 10

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.counter_table.name
    }
  }
}





