# Backend to store tf state file

terraform {
  required_version = ">= 0.13.0"
  backend "s3" {
    endpoint                    = "fra1.digitaloceanspaces.com"
    region                      = "fra1"
    bucket                      = "dam-terraform-state"
    key                         = "dam-vpc"
    access_key                  = ""
    secret_key                  = ""
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
  }
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.19.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.2.2"
    }
  }
}