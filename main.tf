provider "aws" {
  region = "eu-west-2"
}

resource "random_uuid" "my-long-unique-name" {}


module "aws-web-bucket" {
  source         = "./modules/aws-s3-web-bucket"
  s3_bucket-name = "${var.unique-bucket-name.name}-${var.unique-bucket-name.env}-${random_uuid.my-long-unique-name.result}"
}


