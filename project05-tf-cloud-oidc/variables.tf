variable "terraform_cloud_hostname" {
  type        = string
  default     = "app.terraform.io"
  description = "Terraform Cloud hostname, without https://"
}

variable "terraform_cloud_organization" {
  type        = string
  default     = "avinashsain"
  description = "Terraform Cloud or used to organization into AWS."
}

variable "terraform_cloud_audience" {
  type        = string
  default     = "aws.workload.identity"
  description = "Terraform Cloud audience used to authenticate into AWS."
}

variable "admin_role_workspaces" {
  type        = list(string)
  description = "All workspaces that can assume the terraform-cloud-automation-admin role."
}

variable "admin_role_project" {
  type        = list(string)
  description = "Terraform Cloud projects to allow assuming the terraform-cloud-automation-admin role."
}