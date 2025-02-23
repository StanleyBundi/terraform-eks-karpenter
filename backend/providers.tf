# This configuration sets up the AWS provider for Terraform and specifies the required provider version.
provider "aws" {
    region = var.region
    
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
