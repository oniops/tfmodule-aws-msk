################################################################################
# Managed VPC Connections
################################################################################

locals {
  tags = merge(var.context.tags, var.additional_tags)
}

resource "aws_msk_vpc_connection" "this" {
  count              = var.create ? 1 : 0
  authentication     = var.authentication
  target_cluster_arn = var.target_cluster_arn
  vpc_id             = var.vpc_id
  client_subnets     = var.client_subnets
  security_groups    = var.security_groups
  tags               = local.tags
}
