output "bucket_name" {
  value       = module.aws-web-bucket.name
  description = "newly created bucket name"
}

output "bucket_arn" {
  value       = module.aws-web-bucket.arn
  description = "newly created bucket arn"
}

output "bucket_domain" {
  value       = module.aws-web-bucket.domain
  description = "newly created bucket domain"
}

output "cdn-logging-bucket" {
  value       = aws_s3_bucket.cdn-website-logs.id
  description = "cloudfront logging bucket id"
}


output "cloudfront_url" {
  value = aws_cloudfront_distribution.s3-web-bucket.domain_name
}

output "cloudfront-distro-domain" {
  value       = aws_cloudfront_distribution.s3-web-bucket.domain_name
  description = "cloudfront distribution domain name"
}

output "cloudfront-s3-bucked-hosted-id" {
  value       = aws_cloudfront_distribution.s3-web-bucket.hosted_zone_id
  description = "cloudfront ditribution s3 bucket hosted id"
}

output "aws-acm-cert-arn" {
  value = aws_acm_certificate.website-domain-cert.arn
  sensitive   = true
  description = "cloudfront ditribution s3 bucket hosted id"
}

output "aws-acm-SSL-TLS-cert" {
  value = aws_acm_certificate.website-domain-cert.id
  sensitive   = true
  description = "view the SSL/TLS cert"
}
