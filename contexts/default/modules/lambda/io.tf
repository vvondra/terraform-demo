variable "context" {}
variable "environment" {}
variable "country_code" {}
variable "lambda_iam_role_arn" {}
variable "releases_bucket_id" {}
variable "restaurant_api_token" {}
variable "restaurant_api_url" {}

variable "lambda_version" {
  default = "0.0.2"
}

variable "module" {
  default = "lambda"
}

output "lambda_function_arn" {
  value = "${aws_lambda_function.lambda.arn}"
}

output "lambda_function_name" {
  value = "${aws_lambda_function.lambda.function_name}"
}
