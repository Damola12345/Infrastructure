variable "cluster-id" {
    description = "(required) the prefered name for the cluster, either for staging or prod"
    type = string
}

variable "num-cache-nodes" {
    description = "prefered number of nodes"
    type = number
}

variable "project-name" {
    description = "env tag for name"
    type = string
}

variable "env" {
    description = "env tag for enviroment"
    type = string
}

variable "node-type" {
    description = "(required) Instance class to be used"
    type = string
}

variable "snet_group_name" {
  description = "(Required) Name for the cache subnet group"
  type = string
}

variable "subnet_ids" {
  description = "(Required) List of VPC Subnet IDs for the cache subnet group"
  type = list
}