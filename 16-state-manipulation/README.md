# 16 — State Manipulation

Terraform config demonstrating the main ways to manipulate state without
touching real infrastructure out from under your configuration: `import`,
`moved`, `removed`, and the classic CLI equivalents (`terraform import`,
`terraform state mv`, `terraform state rm`, `terraform taint`).

## Files

| File | Purpose |
|---|---|
| `import.tf` | Imports an existing S3 bucket into state, both via the CLI (`terraform import`) and via an `import` block |
| `taint.tf` | A second S3 bucket + access block used to demonstrate `terraform taint` |
| `remove.tf` | A `removed` block showing how to drop a resource from state without destroying it |
| `move-state.tf` | A chain of `moved` blocks tracking a resource as it's renamed, converted to `for_each`, split out, and moved into a module |
| `modules/compute/` | Local module (`aws_instance.this`) that one of the `moved` blocks relocates a resource into |
| `providers.tf` | Terraform/AWS provider configuration (region `us-east-1`) |
| `variables.tf` | `instance_type` input (currently unused by any resource) |

## What each technique shows

### Import (`import.tf`)

- `aws_s3_bucket.remote_state` ("capstone-tfstate-b15") is an S3 bucket that
  already exists in AWS outside of Terraform's state. It's brought under
  management with:
  ```bash
  terraform import aws_s3_bucket.remote_state capstone-tfstate-b15
  ```
- `aws_s3_bucket_public_access_block.remote_state` is imported declaratively
  instead, using an `import` block that targets the bucket created above.

> S3 bucket names are globally unique across *all* AWS accounts. If a bucket
> name is already taken by another account, `terraform apply` fails with
> `BucketAlreadyExists` and there's nothing to import — pick a different,
> unique name instead.

### Taint (`taint.tf`)

- `aws_s3_bucket.tainted` and its `aws_s3_bucket_public_access_block` exist
  purely to demonstrate marking a resource for forced recreation:
  ```bash
  terraform taint aws_s3_bucket.tainted
  terraform apply
  ```
  (On Terraform >= 1.7 you can also do this declaratively by passing
  `-replace=aws_s3_bucket.tainted` to `plan`/`apply`.)

### Removed (`remove.tf`)

- The `removed` block stops Terraform from managing
  `aws_s3_bucket.my_new_bucket` on the next apply, without issuing a destroy
  call (`lifecycle.destroy = false`). The CLI equivalent is:
  ```bash
  terraform state rm aws_s3_bucket.my_new_bucket
  ```

### Moved (`move-state.tf`)

A chain of `moved` blocks lets Terraform follow the same underlying resource
through several refactors in one apply, instead of destroying and recreating
it:

1. `aws_instance.new_list[0]` / `[1]` → `aws_instance.new_list["instance1"]` /
   `["instance2"]` (list → map `for_each`)
2. `aws_instance.new_list["instance1"]` → `aws_instance.new_final` (renamed,
   pulled out of `for_each`)
3. `aws_instance.new_list["instance2"]` → `module.compute.aws_instance.this`
   (moved into a local module)

The CLI equivalent for any single step is `terraform state mv <from> <to>`.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | >= 1.7  |
| aws       | ~> 6.0  |
