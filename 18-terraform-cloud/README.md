# 18 - Terraform Cloud

This example demonstrates using **Terraform Cloud** as the backend for
executing runs and storing state, via the `cloud` block in the Terraform
configuration.

## What this creates

- **Compute** ([compute.tf](compute.tf)): a single EC2 instance running the
  latest Ubuntu 22.04 AMI.
- **Storage** ([s3.tf](s3.tf)): an S3 bucket with a unique name suffixed by a
  random hex ID.
- **Random ID** ([random.tf](random.tf)): an 8-byte random ID used to keep
  the S3 bucket name globally unique.

## Terraform Cloud configuration

The `cloud` block in [provider.tf](provider.tf) points this configuration at
a Terraform Cloud workspace:

```hcl
cloud {
  organization = "avinashsain"

  workspaces {
    name = "terraform-cli"
  }
}
```

Runs are executed remotely in Terraform Cloud, and state is stored there
instead of locally. You'll need to be authenticated via `terraform login`
(or a `TF_TOKEN_<hostname>` environment variable) before running any
commands.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Inputs

| Name              | Description                     | Type   | Default |
| ----------------- | -------------------------------- | ------ | ------- |
| ec2_instance_type | The type of EC2 instance to create. Must be `t2.micro` or `t3.micro`. | string | n/a |

## Outputs

| Name        | Description                           |
| ----------- | -------------------------------------- |
| random_id   | The generated random hex ID.           |
| bucket_name | The name of the created S3 bucket.     |

## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | 1.16.6  |
| aws       | ~> 6.0  |
| random    | ~> 3.5  |
