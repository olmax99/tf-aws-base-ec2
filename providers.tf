provider "aws" {
  alias = "euc1"

  region  = "eu-central-1"
  profile = var.aws_profile

  # Make it faster by skipping something
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}
