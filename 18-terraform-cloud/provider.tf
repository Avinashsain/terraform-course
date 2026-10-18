terraform {
  required_version = "1.16.6"

  cloud {

    organization = "avinashsain"

    workspaces {
      name = "terraform-cli"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      ManagedBy = "Terraform"
      Project   = "terraform-cli"
    }
  }
}