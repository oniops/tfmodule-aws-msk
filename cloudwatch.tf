locals {
  cloudwatch_log_group_name = var.cloudwatch_log_group_name != null ? var.cloudwatch_log_group_name : "/aws/msk/cluster/${local.cluster_name}"
}

resource "aws_cloudwatch_log_group" "cwLog" {
  count = var.create && var.cloudwatch_logs_enabled && var.create_cloudwatch_log_group ? 1 : 0

  name              = local.cloudwatch_log_group_name
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  kms_key_id        = var.cloudwatch_log_group_kms_key_id
  log_group_class   = var.cloudwatch_log_group_class

  tags = merge(
    local.tags,
    { Name = local.cloudwatch_log_group_name }
  )
}