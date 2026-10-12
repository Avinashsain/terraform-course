variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "cost_center" {
  description = "The cost center for the EC2 instance"
  type        = string
  default     = "CC-1234"
}

variable "project_name" {
  description = "The project name for the EC2 instance"
  type        = string
  default     = "15-object-validation"
}