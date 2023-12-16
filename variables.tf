variable "my_region" {
  type        = string
  description = "Your closest AWS region"
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

# S3 Bucket logs for Cloudfront CDN Variables
variable "s3-bucket-logs" {
  type = map(string)
  default = {
    name    = "cdn"
    purpose = "logs"
    website = "joseph-resume"
  }
  description = "logging bucket for hosted S3 bucket"
}
