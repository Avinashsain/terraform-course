locals {
  cidr                 = "10.0.0.0/16"
  private_subnet_cidrs = ["10.0.0.0/24"]
  public_subnet_cidrs  = ["10.0.128.0/24"]
}

data "aws_availability_zones" "azs" {
  state = "available"

}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.7.3"

  cidr            = local.cidr
  name            = local.project_name
  azs             = data.aws_availability_zones.azs.names
  private_subnets = local.private_subnet_cidrs
  public_subnets  = local.public_subnet_cidrs

  tags = local.common_tags
}