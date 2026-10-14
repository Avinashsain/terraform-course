output "lambda_url" {
  value = aws_lambda_function_url.this.function_url
}

output "lambda_function_name" {
  value = aws_lambda_function.this.function_name
}

output "lambda_function_arn" {
  value = aws_lambda_function.this.arn
}