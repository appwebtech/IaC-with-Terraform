output "name" {
  value       = aws_s3_bucket.web_bucket_name.id
  description = "Name of provisioned bucket"
}

output "arn" {
  value       = aws_s3_bucket.web_bucket_name.arn
  description = "Provisioned bucket arn"
}

output "domain" {
  description = "The domain of created bucket"
  value       = aws_s3_bucket_website_configuration.web_bucket_config.website_domain
}

output "s3_bucket_regional_domain_name" {
  value = aws_s3_bucket.web_bucket_name.bucket_regional_domain_name
}