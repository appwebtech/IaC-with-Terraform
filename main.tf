provider "aws" {
  region = "eu-west-2"
}

resource "random_uuid" "my-long-unique-name" {}
resource "random_id" "loggy" {
  byte_length = 4
}

module "aws-web-bucket" {
  source         = "./modules/aws-s3-web-bucket"
  s3_bucket-name = "${var.unique-bucket-name.name}-${var.unique-bucket-name.env}-${random_uuid.my-long-unique-name.result}"
}

# S3 bucket logs, ACL, & ownership controls for Cloudfront CDN
resource "aws_s3_bucket" "cdn-website-logs" {
  bucket = "${var.s3-bucket-logs.name}-${var.s3-bucket-logs.purpose}-${var.s3-bucket-logs.website}.${random_id.loggy.hex}"
  tags = {
    name    = var.s3-bucket-logs["name"]
    purpose = var.s3-bucket-logs["purpose"]
    website = var.s3-bucket-logs["website"]
  }
}

resource "aws_s3_bucket_logging" "cdn-website" {
  bucket = module.aws-web-bucket.name

  target_bucket = aws_s3_bucket.cdn-website-logs.id
  target_prefix = "logs/"
}

resource "aws_s3_bucket_acl" "cdn-bucket-acl" {
  bucket = aws_s3_bucket.cdn-website-logs.id
  acl    = "log-delivery-write"
  depends_on = [
    aws_s3_bucket_ownership_controls.cdn-bucket-acl-ownership
  ]
}

resource "aws_s3_bucket_ownership_controls" "cdn-bucket-acl-ownership" {
  bucket = aws_s3_bucket.cdn-website-logs.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

# S3 Bucket object source and Encryption
resource "aws_s3_object" "bucket-objects" {
  bucket                 = module.aws-web-bucket.name
  for_each               = fileset("./modules/aws-s3-web-bucket/www/", "**")
  key                    = each.value
  content_type           = "text/html"
  source                 = "./modules/aws-s3-web-bucket/www/${each.value}"
  server_side_encryption = "AES256"
  etag                   = filemd5("./modules/aws-s3-web-bucket/www/${each.value}")

  depends_on = [
    module.aws-web-bucket.name
  ]
}

