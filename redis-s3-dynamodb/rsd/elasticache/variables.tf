variable "cluster-name" {
    description = "(required) the prefered name for the cluster, either for staging or prod"
    type = string
}
variable "num-cache-nodes" {
    description = "prefered number of nodes; for staging or prod"
    type = number
    default = 1
}

variable "env" {
    description = "env tag for enviroment"
    type = string
}
variable "node-type" {
    description = "(required) Instance class to be used"
    type = string
}

variable "cidr_block" {
  description = "(Required) The IPv4 CIDR block for the subnet"
  type = string
}

variable "snet_group_name" {
  description = "(Required) Name for the cache subnet group"
  type = string
}