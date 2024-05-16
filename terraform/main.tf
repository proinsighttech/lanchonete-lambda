terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
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