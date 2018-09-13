resource "aws_s3_bucket" "releases" {
  bucket = "${var.context}-${var.environment}-lambda-releases"
  acl    = "private"

  tags {
    Context            = "${var.context}"
    Environment        = "${var.environment}"
    ManagedByTerraform = true
    Module             = "lambda"
  }
}
