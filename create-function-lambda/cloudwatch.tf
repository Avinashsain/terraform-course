resource "aws_cloudwatch_log_group" "lambda" {
  retention_in_days = abs(var.log_retention_days)
  name              = "/aws/lambda/${var.function_name}"
}