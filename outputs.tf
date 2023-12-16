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

# Cloudfront distro url
output "cloudfront_url" {
  value = aws_cloudfront_distribution.s3-web-bucket.domain_name
}