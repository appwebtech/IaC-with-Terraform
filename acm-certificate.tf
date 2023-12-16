resource "aws_acm_certificate" "website-domain-cert" {
  domain_name       = var.website-domain-name
  validation_method = "DNS"
}

# Depends on Route 53 DNS resource (test after checking out branch cloudfront-cdn)
// resource "aws_acm_certificate_validation" "website-domain-validation" {
//   certificate_arn         = aws_acm_certificate.website-domain-cert.arn
//   validation_record_fqdns = [for record in aws_route53_record.website-domain-record : record.fqdn]
// }
