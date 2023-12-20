# Creat HTTP API in API Gateway and integrate with AWS Proxy
resource "aws_iam_policy_attachment" "counter_lambda_policy" {
  name       = var.lambda_attachment
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaRole"
  roles      = [aws_iam_role.counter_lambda_role.name]
}

resource "aws_apigatewayv2_api" "aws-web-bucket_api" {
  name          = var.api-gw-name
  protocol_type = "HTTP"
  target        = aws_lambda_function.counter_lambda.invoke_arn
  cors_configuration {
    allow_origins = ["*"]
  }
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.aws-web-bucket_api.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.counter_lambda.invoke_arn
}

# Permissions to apigw
resource "aws_lambda_permission" "apigw" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.counter_lambda.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.aws-web-bucket_api.execution_arn}/*/*"
}

# Routing
resource "aws_apigatewayv2_route" "lambda_route" {
  api_id     = aws_apigatewayv2_api.aws-web-bucket_api.id
  route_key  = "ANY /{proxy+}"
  target     = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
  depends_on = [aws_apigatewayv2_integration.lambda_integration]
}

# CORS configuration
resource "aws_apigatewayv2_api_mapping" "website_api_mapping" {
  api_id      = aws_apigatewayv2_api.aws-web-bucket_api.id
  domain_name = aws_apigatewayv2_domain_name.aws-web-bucket-domain.id
  stage       = aws_apigatewayv2_stage.website_stage.id
}

resource "aws_apigatewayv2_domain_name" "aws-web-bucket-domain" {
  domain_name = var.website-domain-name

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.website-domain-cert.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
  depends_on = [aws_acm_certificate.website-domain-cert]
}

# Deploy to stage
resource "aws_apigatewayv2_stage" "website_stage" {
  api_id      = aws_apigatewayv2_api.aws-web-bucket_api.id
  name        = var.resource_tags.environment
  auto_deploy = true
}