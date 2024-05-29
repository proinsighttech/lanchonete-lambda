terraform {
    required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket = "snackshop-terraform-state-bucket"
    key    = "lambda-terraform-state"
    region = "us-west-2"
  }
}

provider "aws" {
  region = var.region
}


module "support" {
    environment                     = var.environment
    bucket_name                     = var.bucket_name
    source                          = "./modules"
}