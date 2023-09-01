locals {
  vpc_id = "vpc-0fxxx"
}

data "aws_vpc" "selected" {
  id = local.vpc_id
}

resource "aws_subnet" "snet" {
    vpc_id            = data.aws_vpc.selected.id
    availability_zone = "us-east-1a"
    cidr_block        = var.cidr_block
    tags              = {
        Name = "damola-redis-elasticache"
        Env = var.env
    }
}

module "elasticache" {
    source             = "../../modules/redis-elasticache"
    cluster-id         = var.cluster-name
    node-type          = var.node-type
    num-cache-nodes    = var.num-cache-nodes
    project-name       = "damola"
    env                = var.env
    subnet_ids         = [aws_subnet.snet.id]
    snet_group_name    = var.snet_group_name
}
