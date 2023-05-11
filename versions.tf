terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.66.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }

  // configure backend.tf accordingly
  backend "s3" {}

  required_version = ">= 1.4.0"
}
