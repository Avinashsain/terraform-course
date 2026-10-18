# Project 05 — Terraform Cloud OIDC

Sets up OpenID Connect (OIDC) federation between Terraform Cloud and AWS, so
Terraform Cloud runs can assume an AWS IAM role via short-lived, dynamically
generated credentials instead of long-lived AWS access keys.

## How it works

1. **OIDC provider** ([oidc.tf](oidc.tf)) — an `aws_iam_openid_connect_provider`
   trusts Terraform Cloud (`app.terraform.io`) as an identity provider. Its
   `thumbprint_list` is derived from `data.tls_certificate`, which fetches the
   certificate live from `https://${var.terraform_cloud_hostname}` instead of
   hardcoding the fingerprint.
2. **Admin role** ([oidc.tf](oidc.tf)) — `aws_iam_role.terraform_cloud_admin`
   can be assumed via `sts:AssumeRoleWithWebIdentity` by the OIDC provider,
   gated by two conditions on the JWT claims:
   - `aud` must equal `var.terraform_cloud_audience`.
   - `sub` must match `organization:avinashsain:project:<project>:workspace:<workspace>:run_phase:*`
     for one of the allowed `admin_role_project` / `admin_role_workspaces`
     combinations.
3. **Policy attachment** ([oidc.tf](oidc.tf)) — attaches AWS's managed
   `AdministratorAccess` policy to the role.
4. **S3 bucket** ([s3.tf](s3.tf)) — a sample resource (name suffixed with a
   random hex ID) that a Terraform Cloud run using the role above could
   create, to prove the federation works end to end.

## Files

| File | Purpose |
|---|---|
| `provider.tf` | Terraform/provider requirements and the `cloud` block pointing at the `terraform-oidc` TFC workspace |
| `oidc.tf` | OIDC provider, admin IAM role, assume-role policy, and policy attachment (plus `import` blocks for pre-existing resources) |
| `s3.tf` | Sample S3 bucket with a random suffix |
| `variables.tf` | Input variable declarations |
| `terraform.tfvars` | Variable values (not committed with real values — fill in before applying) |

## Inputs

| Name | Type | Default | Notes |
|---|---|---|---|
| `terraform_cloud_hostname` | `string` | `app.terraform.io` | Hostname of the Terraform Cloud instance, without `https://` |
| `terraform_cloud_audience` | `string` | `aws.workload.identity` | Audience value Terraform Cloud sends in its OIDC token |
| `admin_role_workspaces` | `list(string)` | — | Required. Terraform Cloud workspaces allowed to assume the admin role |
| `admin_role_project` | `list(string)` | — | Required. Terraform Cloud projects allowed to assume the admin role |

## Usage

```bash
terraform init
terraform plan
terraform apply
```

Since `oidc.tf` contains `import` blocks for the OIDC provider, the admin
role, and its policy attachment, the first `apply` will try to import those
as existing AWS resources rather than create them. If they don't already
exist under the given IDs, remove the relevant `import` block (or run
`terraform plan` first to see which imports fail) so Terraform creates them
instead.

## Notes

- The IAM role name (`terrform-cloud-automation-admin` in
  `aws_iam_role.terraform_cloud_admin`) is misspelled (missing the second
  "a" in "terraform"). The `import` block for this role on line 8 must use
  whatever name actually exists in AWS — fix the mismatch before relying on
  the import.
- The `sub` condition hardcodes the Terraform Cloud organization as
  `avinashsain`; this looks like a leftover from a course template and
  likely needs to be the organization configured in `provider.tf`
  (`avinashsain`) instead.
- The admin role gets `AdministratorAccess`, which is intentionally broad for
  this learning exercise — scope it down before using this pattern for real
  workloads.
