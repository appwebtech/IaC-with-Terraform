variable "my_region" {
  type        = string
  description = "Your closest AWS region"
}

variable "web-page_counter" {
  type        = string
  description = "Counter for page visits"
}

variable "resource_tags" {
  type = map(string)
  default = {
    resource    = "s3-bucket"
    environment = "prod"
  }
  description = "resource tags"
}


variable "unique-bucket-name" {
  type = map(string)
  default = {
    name = "www"
    env  = "josephmwania"
  }
  description = "A unique bucket name with a randomized suffix"
}

variable "website-domain-name" {
  type        = string
  description = "website domain name"
}

# S3 Bucket logs for Cloudfront CDN
variable "s3-bucket-logs" {
  type = map(string)
  default = {
    name    = "cdn"
    purpose = "logs"
    website = "joseph-resume"
  }
  description = "logging bucket for hosted S3 bucket"
}

# API Gateway / Lambda / DynamoDB 
variable "api-gw-name" {
  type        = string
  description = "AWS API Gateway name"
}

variable "lambda_role" {
  type        = string
  description = "Name of my web page lambda role"
}

variable "lambda-attributes" {
  type = map(string)
  default = {
    filename      = "counter_lambda.zip"
    function_name = "website_counter_lambda"
    handler       = "lambda_function.handler"
    runtime       = "python3.8"
    timeout       = 10
  }
  description = "description"
}


variable "lambda_attachment" {
  type        = string
  description = "Website lambda attachment"
}

variable "dynamoDB-policy" {
  type        = string
  description = "DynamoDB policy name"
}

variable "dynamoDB-attributes" {
  type = map(string)
  default = {
    name        = "DynamoDBPolicy"
    description = "IAM policy for DynamoDB access"
  }
  description = "DynamoDB name and description"
}