variable "region" {
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
    name = "your-bucket-name"
    env  = "prod"
  }
  description = "A unique bucket name with a randomized suffix"
}
