resource "random_id" "bucket_suffix" {
  byte_length = 8
}

/*
dev -> 1 bucket
prod -> 3 buckets
stag -> 2 bucket
*/

/*resource "aws_s3_bucket" "this" {
  count  = terraform.workspace == "prod" ? 3 : terraform.workspace == "stag" ? 2 : 1
  bucket = "workspaces-demo-${terraform.workspace}-${count.index + 1}-${random_id.bucket_suffix.hex}"
}*/

resource "aws_s3_bucket" "this" {
  count  = var.bucket_count
  bucket = "workspaces-demo-${terraform.workspace}-${count.index + 1}-${random_id.bucket_suffix.hex}"
}
