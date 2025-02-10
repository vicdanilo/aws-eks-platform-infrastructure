########################################
# Provider to connect to AWS
########################################

terraform {
  required_version = ">= 1.0"
  # backend "s3" {} # use backend.config for remote backend

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.8"
    }
  }
}

provider "aws" {
  region = var.region
}