module "database" {
  source = "./modules/rds"

  project_name = "project04-rds-module"
  security_group_ids = [
    aws_security_group.compliant.id
  ]
  subnet_ids = [
    aws_subnet.private1.id,
    aws_subnet.private2.id
  ]
  credentials = {
    username = "dreamcatcher"
    password = "CloudDev123"
  }
}