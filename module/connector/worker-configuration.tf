locals {
  create_worker_configuration   = var.worker_configuration_arn == null ? true : false
  worker_configuration_name     = var.worker_configuration_fullname != null ? var.worker_configuration_fullname : "${local.name_prefix}-${var.connector_name}-wkcfg"
  worker_configuration_arn      = local.create_worker_configuration ? aws_mskconnect_worker_configuration.this[0].arn : var.worker_configuration_arn
  worker_configuration_revision = local.create_worker_configuration ?
    aws_mskconnect_worker_configuration.this[0].latest_revision : var.worker_configuration_revision
}

resource "aws_mskconnect_worker_configuration" "this" {
  count       = local.create_worker_configuration ? 1 : 0
  name        = local.worker_configuration_name
  description = var.worker_configuration_description
  properties_file_content = join("\n", [for k, v in var.properties_file_content : format("%s = %s", k, v)])

  tags = merge(local.tags, var.worker_configuration_tags,
    { Name = local.worker_configuration_name }
  )
}
