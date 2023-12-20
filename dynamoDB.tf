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
  name        = var.dynamoDB-attributes.name
  description = var.dynamoDB-attributes.description

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

#--------------------------------------------------------------------------------------------------------------------------------------
# Lambda (There is a known issue with Botocore throwing 'DEPRECATED_SERVICE_NAMES' even though I was using the latest Python version.)
# I had to downgrade my Boto3 libraries to 1.26.90 and repackaged the binaries again prior to uploading to AWS Lambda
# Issue is tracked here: https://github.com/boto/boto3/issues/3648
#--------------------------------------------------------------------------------------------------------------------------------------
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





