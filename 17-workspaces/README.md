# 17 — Workspaces

Terraform config demonstrating CLI workspaces: how the same configuration can
provision different amounts of infrastructure per environment (`dev`,
`stag`, `prod`) using `terraform.workspace` and per-workspace `.tfvars` files.

## Files

| File | Purpose |
|---|---|
| `provider.tf` | Terraform/AWS/random provider configuration (region `us-east-1`) |
| `variables.tf` | `bucket_count` input — number of S3 buckets to create |
| `s3.tf` | `aws_s3_bucket.this`, created `var.bucket_count` times, named with `terraform.workspace` and a random suffix |
| `dev.tfvars` | `bucket_count = 1` |
| `stag.tfvars` | `bucket_count = 2` |
| `prod.tfvars` | `bucket_count = 3` |

## What this shows

- `terraform workspace new <name>` creates an isolated state file per
  environment (tracked under `terraform.tfstate.d/`), so `dev`, `stag`, and
  `prod` each manage their own copy of the same resources without clobbering
  one another.
- `s3.tf` uses `terraform.workspace` in the bucket name so resources from
  different workspaces never collide, and `count = var.bucket_count` so each
  environment can provision a different amount of infrastructure from one
  config.
- Workspace-specific sizing is driven by matching `.tfvars` files
  (`dev.tfvars`, `stag.tfvars`, `prod.tfvars`) rather than hardcoding the
  mapping in `.tf` code. (An earlier, commented-out version of
  `aws_s3_bucket.this` in `s3.tf` shows the alternative: a conditional
  expression on `terraform.workspace` baked directly into the resource.)

## Usage

```bash
terraform init

# create one workspace per environment
terraform workspace new dev
terraform workspace new stag
terraform workspace new prod

terraform workspace list
terraform workspace select dev

# apply using the matching .tfvars file for the selected workspace
terraform apply -var-file="$(terraform workspace show).tfvars"
```

A couple of shell aliases make the apply/destroy loop less repetitive when
switching between workspaces:

```bash
alias tf_apply='terraform apply -var-file="$(terraform workspace show).tfvars"'
alias tf_destroy='terraform destroy -var-file="$(terraform workspace show).tfvars"'
```

To tear everything down:

```bash
terraform workspace select dev   && tf_destroy
terraform workspace select stag  && tf_destroy
terraform workspace select prod  && tf_destroy

# switch back to default before deleting the now-empty workspaces
terraform workspace select default
terraform workspace delete dev
terraform workspace delete stag
terraform workspace delete prod
```

> `terraform workspace delete` only works once a workspace's state is empty
> (i.e. after `destroy`), and you can't delete the workspace you currently
> have selected — select `default` first.

## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | ~> 1.7  |
| aws       | ~> 6.0  |
| random    | ~> 3.5  |
