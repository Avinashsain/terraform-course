variable "ec2_instance_type" {
  type        = string
  description = "The type of EC2 instance to create."

  validation {
    condition     = contains(["t2.micro", "t3.micro"], var.ec2_instance_type)
    error_message = "The EC2 instance type must be either 't2.micro' or 't3.micro'."
  }
}