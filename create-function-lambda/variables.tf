variable "function_name" {
  description = "The name of the Lambda function"
  type        = string
  default     = "terraform-created-lambda"
}

variable "role_name" {
  description = "The name of the IAM role for the Lambda function"
  type        = string
  default     = "terraform-created-lambda-role"
}

variable "filename" {
  description = "The path to the deployment package for the Lambda function"
  type        = string
  default     = "lambda.zip"
}

variable "handler" {
  description = "The function within your code that Lambda calls to begin execution"
  type        = string
  default     = "index.handler"
}

variable "description" {
  description = "The description of the Lambda function"
  type        = string
  default     = "A starter AWS Lambda function."
}

variable "runtime" {
  description = "The runtime environment for the Lambda function"
  type        = string
  default     = "nodejs22.x"
}

variable "log_retention_days" {
  description = "The number of days to retain CloudWatch logs for the Lambda function"
  type        = number
  default     = 14
}