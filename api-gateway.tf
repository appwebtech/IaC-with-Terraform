# Creat HTTP API in API Gateway and integrate with AWS Proxy
resource "aws_iam_policy_attachment" "counter_lambda_policy" {
  name       = "website_counter_lambda_attachment"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaRole"
  roles      = [aws_iam_role.counter_lambda_role.name]
}

resource "aws_apigatewayv2_api" "aws-web-bucket_api" {
  name          = "aws-web-bucket-api"
  protocol_type = "HTTP"
  target        = aws_lambda_function.counter_lambda.invoke_arn
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.aws-web-bucket_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.counter_lambda.invoke_arn
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
}

# Deploy to stage
resource "aws_apigatewayv2_stage" "website_stage" {
  api_id      = aws_apigatewayv2_api.aws-web-bucket_api.id
  name        = "prod"
  auto_deploy = true
}