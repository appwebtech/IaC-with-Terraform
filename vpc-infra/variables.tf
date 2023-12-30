variable "vpc_cidr_block" {
  type        = string
  description = "vpc cidr block"
}

variable "aws_region" {
  type        = string
  default     = "eu-west-2"
  description = "AWS region"
}

variable "aws_account_id" {
  type        = string
  description = "AWS account"
}

variable "instance_names" {
  type = map(string)
  default = {
    name = "web-app"
    app  = "prod"
  }
  description = "Ec2 instance tags"
}

variable "instance_type" {
  type = map(string)
  default = {
    "small-apps"  = "t3.micro"
    "medium-apps" = "t3.small"
    "large-apps"  = "t3.large"
  }
  description = "choose instance type"
}

variable "cidr_range_public_subnet" {
  description = "CIDR ranges for public subnets."
  type        = list(string)
  default = [
    "10.0.0.0/20",
    "10.0.16.0/20",
    "10.0.32.0/20",
    "10.0.48.0/20",
    "10.0.64.0/20",
    "10.0.80.0/20",
    "10.0.96.0/20",
    "10.0.112.0/20",
  ]
}

variable "cidr_range_private_subnet" {
  description = "CIDR ranges for private subnets."
  type        = list(string)
  default = [
    "10.0.128.0/20",
    "10.0.144.0/20",
    "10.0.160.0/20",
    "10.0.176.0/20",
    "10.0.192.0/20",
    "10.0.208.0/20",
    "10.0.224.0/20",
    "10.0.240.0/20",
  ]
}

variable "generic_names" {
  type = map(string)
  default = {
    name = "web-app"
    app  = "prod"
  }
  description = "Generic names for infra resources"

  validation {
    condition     = length(var.generic_names["name"]) <= 16 && length(regexall("[^a-zA-Z0-9-]", var.generic_names["name"])) == 0
    error_message = "The project tag must be no more than 16 characters, and only contain letters, numbers, and hyphens."
  }

  validation {
    condition     = length(var.generic_names["app"]) <= 8 && length(regexall("[^a-zA-Z0-9-]", var.generic_names["app"])) == 0
    error_message = "The environment tag must be no more than 8 characters, and only contain letters, numbers, and hyphens."
  }

}

