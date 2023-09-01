resource "aws_elasticache_subnet_group" "snet_group_elasticache" {
  name       = var.snet_group_name
  subnet_ids = var.subnet_ids
}

resource "aws_elasticache_cluster" "elasticache" {
  cluster_id           = var.cluster-id
  engine               = "redis"
  node_type            = var.node-type
  num_cache_nodes      = var.num-cache-nodes
  parameter_group_name = "default.redis6.x"
  engine_version       = "6.2"
  port                 = 6379
  availability_zone    = "us-east-1a"
  subnet_group_name    = aws_elasticache_subnet_group.snet_group_elasticache.name
  tags                 = {
    Name = var.project-name
    Env = var.env
  }
}