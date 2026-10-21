terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "demo_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = "demo-bucket"
    Environment = "Dev"
  }
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "demo-bucket-terraform-2026"
}

output "bucket_id" {
  value = aws_s3_bucket.demo_bucket.id
}

locals {
  local_exaample = "This is a local variable"
}