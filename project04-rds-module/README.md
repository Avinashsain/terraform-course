# Project 04 — RDS Module

Terraform config that provisions a PostgreSQL RDS instance through a
reusable local module (`modules/rds`), with networking guardrails that
validate the subnets and security groups passed into it.

## How it works

1. **Networking** (`networking.tf`) creates a custom VPC with two private
   subnets, one public subnet, and three security groups:
   - `source` — the SG allowed to connect to the database.
   - `compliant` — allows inbound Postgres (5432) only from `source`, via
     `referenced_security_group_id` (no open CIDR ranges).
   - `non_compliant` — included for documentation only, allows inbound
     443 from `0.0.0.0/0`. Not wired into the RDS module.
2. **RDS module** (`modules/rds`) takes subnet IDs, security group IDs,
   credentials, and DB sizing/version as input, and creates the DB subnet
   group, parameter group, and `aws_db_instance`.
3. **Validation** (`modules/rds/networking-validation.tf`) reads back the
   subnets and security group rules via data sources and fails the plan
   (via `postcondition`) if:
   - A subnet belongs to the default VPC.
   - A subnet isn't tagged `Access = "private"`.
   - A security group has an inbound rule that allows traffic from a CIDR
     block instead of a referenced security group.

## Files

| File | Purpose |
|---|---|
| `networking.tf` | VPC, subnets, and security groups |
| `rds.tf` | Calls `module.database` with project inputs |
| `outputs.tf` | Exposes the RDS endpoint |
| `provider.tf` | AWS provider config |
| `modules/rds/rds.tf` | DB subnet group, parameter group, and `aws_db_instance` |
| `modules/rds/variables.tf` | Module inputs (sizing, engine, credentials, networking) |
| `modules/rds/outputs.tf` | RDS ARN, ID, address, port, and endpoint |
| `modules/rds/networking-validation.tf` | Postcondition checks on subnets and SG rules |

## Module inputs (`modules/rds`)

| Variable | Default | Notes |
|---|---|---|
| `project_name` | — | Required. Used to name resources and tags. |
| `instance_class` | `db.t3.micro` | Only free-tier class is allowed. |
| `storage_size` | `10` | GB, must be 5–10. |
| `engine` | `postgres-latest` | `postgres-latest` (16.x) or `postgres-14`. |
| `backup_retention_period` | `7` | Days, must be 1–35. |
| `credentials` | — | Required, sensitive. `{ username, password }`; password needs a letter, a digit, 8+ chars. |
| `subnet_ids` | — | Required. Must be private, non-default-VPC subnets. |
| `security_group_ids` | — | Required. Must only allow ingress from referenced SGs, not CIDR blocks. |

## Usage

```bash
terraform init
terraform apply
```

Because `rds.tf` passes `aws_security_group.compliant.id` (a resource
created in this same configuration) into the module, and the module's
validation needs to read that security group's rules back from AWS, a
**fresh `apply` from scratch will fail** with an `Invalid for_each
argument` error — the rule IDs aren't known until the security group and
its rule actually exist. Work around it with a two-phase apply:

```bash
terraform apply -target=aws_security_group.compliant \
  -target=aws_vpc_security_group_ingress_rule.db \
  -target=aws_subnet.private1 \
  -target=aws_subnet.private2
terraform apply
```

## Notes

- `engine_version` is pinned to specific patch versions in
  `modules/rds/rds.tf` (`local.db_engine`). AWS periodically deprecates old
  RDS engine versions — if `apply` fails with `Cannot find version X for
  postgres`, check currently supported versions with:
  ```bash
  aws rds describe-db-engine-versions --engine postgres \
    --query "DBEngineVersions[].EngineVersion" --output table
  ```
  and bump the pinned version accordingly.
- `skip_final_snapshot = true` — destroying the instance does not create a
  final snapshot. Fine for this course project, not for production.
- Credentials are passed in plaintext via `rds.tf` and will land in
  `terraform.tfstate` — treat the state file as sensitive and don't commit
  it (already covered by `.gitignore`).
