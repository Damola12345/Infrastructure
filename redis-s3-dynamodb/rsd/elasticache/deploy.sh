#!/usr/bin/env bash

# Terraform plan for staging
terraform plan -var-file environments/staging.tfvars -out main.tfplan

# Terraform plan for prod
terraform plan -var-file environments/prod.tfvars -out main.tfplan

# Terraform apply
terraform apply -auto-approve main.tfplan