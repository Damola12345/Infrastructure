variable "cluster_name" {
  description = "Name of cluster - used by Terratest for e2e test automation"
  type        = string
  default     = "damola-prod"
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "prod"
}