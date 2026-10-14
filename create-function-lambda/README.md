# Create Function Lambda

Terraform config that builds a Lambda function entirely from scratch — IAM
role, IAM policy, CloudWatch log group, the function itself, and a public
function URL — with no manual console setup or `import` blocks involved.

## How it works

1. **IAM role** (`iam.tf`) is created with a trust policy that only allows
   `lambda.amazonaws.com` to assume it.
2. **IAM policy** (`iam.tf`) grants `logs:CreateLogGroup` account-wide and
   `logs:CreateLogStream` / `logs:PutLogEvents` scoped to the function's own
   log group, then attaches it to the role alongside the AWS-managed
   `AWSLambdaBasicExecutionRole` policy.
3. **CloudWatch log group** (`cloudwatch.tf`) is created up front at
   `/aws/lambda/<function_name>` with a configurable retention period.
4. **Lambda function** (`lambda.tf`) is packaged from `build/index.mjs` via
   `data.archive_file` and deployed with the IAM role above.
5. **Function URL** (`lambda.tf`) exposes the function publicly
   (`authorization_type = "NONE"`), with a matching `aws_lambda_permission`
   allowing the function URL service to invoke it.

## Files

| File | Purpose |
|---|---|
| `provider.tf` | AWS provider config + default tags |
| `variables.tf` | Configurable inputs (function name, role name, runtime, retention, etc.) |
| `iam.tf` | IAM role, execution policy, and policy attachments |
| `cloudwatch.tf` | CloudWatch log group for the function |
| `lambda.tf` | `archive_file` packaging, the Lambda function, function URL, and invoke permission |
| `outputs.tf` | Function URL, function name, function ARN |
| `build/index.mjs` | Lambda handler source, zipped at plan/apply time |

## Variables

| Variable | Default | Description |
|---|---|---|
| `function_name` | `terraform-created-lambda` | Name of the Lambda function |
| `role_name` | `terraform-created-lambda-role` | Name of the IAM execution role |
| `filename` | `lambda.zip` | Deployment package path |
| `handler` | `index.handler` | Function entry point |
| `description` | `A starter AWS Lambda function.` | Function description |
| `runtime` | `nodejs22.x` | Lambda runtime |
| `log_retention_days` | `14` | CloudWatch log retention |

## Usage

```bash
terraform init
terraform plan
terraform apply
```

Change any default by passing `-var`, a `.tfvars` file, or editing
`variables.tf` directly.

## Outputs

- `lambda_function_name` / `lambda_function_arn`
- `lambda_url` — the public invoke URL for the function

## Notes

- `aws_iam_policy.lambda_execution` has a hardcoded `name` left over from a
  different exercise (`project03-import-lambda`'s manually-created policy
  UUID) — it has no special meaning here and can be renamed freely.
- The function URL has **no authorization** — anyone with the URL can invoke
  it. Fine for this exercise, not for production.
