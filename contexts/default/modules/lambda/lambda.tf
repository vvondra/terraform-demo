resource "aws_lambda_function" "lambda" {
  function_name = "${var.context}-${var.environment}-restaurant-ingestion-${var.country_code}"
  handler       = "handler.restaurant_ingestor"
  runtime       = "python3.6"

  role = "${var.lambda_iam_role_arn}"

  s3_bucket = "${var.releases_bucket_id}"
  s3_key    = "${var.lambda_version}.zip"

  timeout = 300

  environment {
    variables = {
      COUNTRY_CODE         = "${var.country_code}"
      RESTAURANT_API_TOKEN = "${var.restaurant_api_token}"
      RESTAURANT_API_URL   = "${var.restaurant_api_url}"
    }
  }

  tags {
    Context            = "${var.context}"
    Environment        = "${var.environment}"
    ManagedByTerraform = true
    Module             = "${var.module}"
  }
}
