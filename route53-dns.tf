# R53 zone
resource "aws_route53_zone" "aws-s3-web-bucket-r53" {
  name = var.website-domain-name
}

# Use the already registered record and ns servers in R53
resource "aws_route53domains_registered_domain" "jose-AWS-domain-registered" {
  domain_name = "josephmwania.com"

  name_server {
    name = "ns-448.awsdns-56.com."
  }
  name_server {
    name = "ns-1796.awsdns-32.co.uk."
  }
  name_server {
    name = "ns-651.awsdns-17.net."
  }
  name_server {
    name = "ns-1250.awsdns-28.org."
  }

  tags = {
    resource    = var.resource_tags["resource"],
    environment = var.resource_tags["environment"]
  }
}

# Spin a new record in R53
// resource "aws_route53_record" "www-s3-web-bucket" {
//   zone_id = aws_route53_zone.aws-s3-web-bucket-r53.zone_id
//   name    = "${var.website-domain-name}"
//   type    = "A"
//   // ttl     = 300
//   // records = [aws_eip.lb.public_ip]

//   alias {
//     name                   = aws_cloudfront_distribution.s3-web-bucket.domain_name
//     zone_id                = aws_cloudfront_distribution.s3-web-bucket.hosted_zone_id
//     evaluate_target_health = false
//   }
// }



# R53 ACM Certificate validation
resource "aws_route53_record" "aws-s3-web-bucket-cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.website-domain-cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name    = each.value.name
  type    = each.value.type
  zone_id = aws_route53_zone.aws-s3-web-bucket-r53.id
  records = [each.value.record]
  ttl     = 60
}