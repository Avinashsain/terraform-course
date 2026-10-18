resource "random_id" "bucket_suffix" {
  byte_length = 8
}

resource "aws_s3_bucket" "this" {
  bucket = "terraform-cloud-oidc-${random_id.bucket_suffix.hex}"
  tags = {
    ManagedBy = "Terraform Cloud"
    Project   = "project05-tf-cloud-oidc"
  }
}