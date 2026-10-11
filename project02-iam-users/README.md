# Project 02 — IAM Users & Role-Based Access

Terraform config that creates IAM users and gives them access to AWS services
through assumable IAM roles (not direct user policies).

## How it works

1. **Users** (`users.tf`) are created from `user-roles.yaml`, each with a login
   profile (console password).
2. **Roles** (`roles.tf`) are created per role name in `local.role_policies`,
   each with AWS managed policies attached.
3. Each role's trust policy allows only the users listed against it in
   `user-roles.yaml` to assume it.
4. Each user also gets an inline policy granting `sts:AssumeRole`, scoped to
   just the roles they're allowed to use.

Users have **no permissions on their own identity** — they must switch role
(console) or call `sts:AssumeRole` (CLI/SDK) to get access.

## Files

| File | Purpose |
|---|---|
| `user-roles.yaml` | Source of truth: which users exist and which roles each can use |
| `users.tf` | `aws_iam_user` + `aws_iam_user_login_profile` resources |
| `roles.tf` | `aws_iam_role`, managed policy attachments, trust policies, and the per-user `sts:AssumeRole` permission |
| `provider.tf` | AWS provider config |

## Current users & roles

| User | Roles |
|---|---|
| john | `readonly`, `developer` |
| jane | `admin`, `auditor` |
| lauro | `readonly` |

## Roles & attached policies

| Role | Managed Policies |
|---|---|
| `readonly` | `ReadOnlyAccess` |
| `admin` | `AdministratorAccess` |
| `auditor` | `SecurityAudit` (includes broad `ec2:Describe*` etc. for audit purposes) |
| `developer` | `AmazonVPCFullAccess`, `AmazonEC2FullAccess`, `AmazonRDSFullAccess`, `AmazonS3FullAccess`, `AmazonDynamoDBFullAccess` |

## Usage

### Get a user's console password

```bash
terraform output passwords
```

Output is marked `sensitive` — use the command above to reveal it (not
`terraform output` alone). Password reset is required on first login.

### Use a role after logging in

**Console:** top-right menu → **Switch Role** → Account ID
`251478238405` → Role name (e.g. `developer`).

**CLI:**

```bash
aws sts assume-role \
  --role-arn arn:aws:iam::251478238405:role/developer \
  --role-session-name john-dev-session \
  --profile john
```

Use the returned temporary credentials (`AccessKeyId`, `SecretAccessKey`,
`SessionToken`) — a user's own long-term keys carry no permissions.

## Adding/changing users or roles

- Add or edit users in `user-roles.yaml` (`username` + `roles` list).
- Add or edit roles/policies in `local.role_policies` in `roles.tf`.
- Run `terraform plan` / `terraform apply` after changes.

## Notes

- `terraform.tfstate` contains plaintext login passwords — treat it as
  sensitive and never commit it (already covered by `.gitignore`).
