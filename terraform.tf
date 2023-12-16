# This terraform block houses a nested cloud block with arguments in which attributes must be configured in TF cloud.
# The 'organization' and 'name' values will need to be substituted with your own values if you want to store your state file remotely in TF Cloud.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.31.0"
    }
  }
  required_version = "~> 1.6.5"

  cloud {
    organization = "AWS-Cloud-Resume-2023"
    workspaces {
      name = "joseph-mwania-website"
    }
  }
}
