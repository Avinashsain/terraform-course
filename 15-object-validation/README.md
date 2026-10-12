# 15 - Object Validation

This example demonstrates Terraform's validation features for catching
misconfigurations: `lifecycle.postcondition` blocks on resources, and
standalone `check` blocks for broader, non-blocking assertions.

## What this creates

- **Networking** ([networking.tf](networking.tf)): 4 subnets spread across the
  default VPC's available availability zones.
- **Compute** ([compute.tf](compute.tf)): a single EC2 instance running the
  latest Ubuntu 22.04 AMI, placed in the first subnet.

## Validation in use

### Postconditions (enforced, block apply)

- `aws_subnet.this` — verifies the chosen availability zone is actually one
  of the AZs available in the region.
- `aws_instance.this` — verifies `instance_type` is one of the
  `allowed_instance_types` (`t2.micro`, `t3.micro`) defined in `locals`.

### Check blocks (warn only, never block apply)

- `check.high_availability_check` — warns if all subnets ended up in the
  same AZ instead of being spread out for high availability.
- `check.cost_center_check` — warns if the EC2 instance is missing a
  `CostCenter` tag.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Inputs

| Name          | Description                        | Type   | Default      |
| ------------- | ----------------------------------- | ------ | ------------ |
| instance_type | The instance type for the EC2 instance | string | `t2.micro`   |

## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | >= 1.7  |
| aws       | ~> 6.0  |
