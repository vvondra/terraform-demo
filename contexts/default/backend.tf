terraform {
  backend "s3" {
    bucket  = "CHANGEME"
    key     = "logistics-infra-terraform-state.tfstate"
    region  = "eu-west-1"
    profile = "CHANGEME"
  }
}
