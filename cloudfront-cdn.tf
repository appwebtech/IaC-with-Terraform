locals {
  s3_origin_id = "myS3Origin"
}


resource "aws_cloudfront_distribution" "s3-web-bucket" {
  origin {
    domain_name = module.aws-web-bucket.s3_bucket_regional_domain_name
    origin_id   = local.s3_origin_id
  }

  depends_on = [
    aws_s3_bucket.cdn-website-logs
  ]

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Website CloudFront CDN"
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = "${aws_s3_bucket.cdn-website-logs.id}.s3.amazonaws.com"
    prefix          = "logs/cdn"
  }

  // aliases = ["mysite.example.com", "yoursite.example.com"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = module.aws-web-bucket.s3_bucket_regional_domain_name
    compress         = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id
    cache_policy_id  = data.aws_cloudfront_cache_policy.caching-optimized.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = [] # ["US", "CA", "GB", "DE"]
    }
  }
  tags = {
    resource = var.resource_tags["environment"]
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    acm_certificate_arn            = aws_acm_certificate.website-domain-cert.arn
  }
}

# CloudFront access origin control
resource "aws_cloudfront_origin_access_control" "aws-web-bucket" {
  name                              = module.aws-web-bucket.s3_bucket_regional_domain_name
  description                       = "origin acccess policy for CDN to access S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_cloudfront_cache_policy" "caching-optimized" {
  name = "Managed Caching Optimized"
}