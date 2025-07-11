terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0"
    }
  }
  backend "s3" {
    bucket = "viviennedotsey-terraform-state-eu-n1"
    key    = "netflix/terraform.tfstate"
    region = "eu-north-1"
  }

  required_version = ">= 1.0.0"
}

provider "aws" {
  region = var.aws_region
}
