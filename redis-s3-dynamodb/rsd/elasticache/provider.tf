terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.47"
    }
  }

  backend "s3" {
    bucket         = "terraform-redis-state"
    key            = "redis-elasticache/terraform.tfstate"
    region         = "us-east-1"
    # For state lock
    dynamodb_table = "terraform-redis-locks"
    encrypt        = true
  }
}

provider "aws" {
  region  = "us-east-1"

}