module "vpc" {
  source  = "devops-avinashsain/networking-tf-course/aws"
  version = "~> 0.2"

  vpc_config = {
    cidr_block = "10.0.0.0/16"
    name       = "my-networking-vpc"
  }

  subnet_config = {
    subnet_1 = {
      cidr_block = "10.0.0.0/24"
      az         = "us-east-1a"
    }
    subnet_2 = {
      cidr_block = "10.0.1.0/24"
      # Public subnets are indicated by setting the "public" option to true.
      public = true
      az     = "us-east-1b"
    }
  }
}
