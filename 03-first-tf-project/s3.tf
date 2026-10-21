resource "random_id" "bucket_suffix" {
  byte_length = 6
}

resource "aws_s3_bucket" "demo_bucket" {
  bucket = "${var.bucket_name}-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "demo-bucket"
    Environment = "Dev"
  }
}

output "bucket_id" {
  value = aws_s3_bucket.demo_bucket.bucket
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "demo-bucket-terraform-2026"
}