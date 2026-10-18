resource "random_id" "this" {
  byte_length = 8
}

output "random_id" {
  value = random_id.this.hex
}