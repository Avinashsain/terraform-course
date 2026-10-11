locals {
  project_name = "12-public-modules-vpc"
  common_tags = {
    Project     = local.project_name
    Managed-by  = "Terraform"
    Environment = "dev"
  }
}