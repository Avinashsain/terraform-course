resource "aws_s3_bucket" "tf_cloud" {
  bucket = "terraform-cli-${random_id.this.hex}"
  tags = {
    ManagedBy = "Terraform"
    Project   = "terraform-cli"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.tf_cloud.bucket
}