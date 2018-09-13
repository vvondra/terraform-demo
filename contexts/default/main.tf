provider "aws" {
  profile = "${var.aws_profile}"
  region  = "${var.region}"

  version = ">= 1.24, <= 1.24"
}
