# 12 — Public Modules (VPC + EC2)

Terraform config that provisions a VPC and a public EC2 instance using the
community `terraform-aws-modules` registry modules, instead of hand-rolled
resources.

## How it works

1. **Networking** (`networking.tf`) creates a VPC via the
   [`terraform-aws-modules/vpc/aws`](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws)
   module, spanning all available AZs in the region with one private and one
   public subnet CIDR.
2. **Compute** (`compute.tf`) looks up the latest Ubuntu 22.04 AMI and launches
   an EC2 instance via the
   [`terraform-aws-modules/ec2-instance/aws`](https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws)
   module, placed in the VPC's public subnet.
3. **Shared data** (`shared-data.tf`) holds the project name and common tags
   applied across resources.

## Files

| File | Purpose |
|---|---|
| `provider.tf` | Terraform/AWS provider configuration (region `us-east-1`) |
| `shared-data.tf` | Project name and common tags shared across modules |
| `networking.tf` | VPC module: CIDR, AZs, public/private subnets |
| `compute.tf` | Ubuntu AMI lookup + EC2 instance module |

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Notes / gotchas

- **AMI owner ID**: `data.aws_ami.ubuntu` must use Canonical's AWS account ID
  (`099720109477`), not your own account ID — otherwise the AMI filter
  returns zero results.
- **`subnet_id` is required**: the `ec2-instance` module's internal
  `data "aws_subnet" "this"` looks up by `id = var.subnet_id`. If `subnet_id`
  is left unset, the filter is empty and the lookup matches every subnet in
  the account ("multiple EC2 Subnets matched"), so it must be set explicitly
  (e.g. `module.vpc.public_subnets[0]`).
- The instance uses the VPC's default security group
  (`module.vpc.default_security_group_id`) rather than creating a new one.
