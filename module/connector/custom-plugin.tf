locals {
  create_plugin   = var.plugin_arn == null ? true : false
  connector_name  = var.connector_fullname != null ? var.connector_fullname : "${local.name_prefix}-${var.connector_name}-plugin"
  plugin_arn      = local.create_plugin ? aws_mskconnect_custom_plugin.this[0].arn : var.plugin_arn
  plugin_revision = local.create_plugin ? aws_mskconnect_custom_plugin.this[0].latest_revision : var.plugin_revision
}

resource "aws_mskconnect_custom_plugin" "this" {
  count        = local.create_plugin ? 1 : 0
  name         = localconnector_name
  description  = var.plugin_description
  content_type = var.content_type

  location {
    s3 {
      bucket_arn = var.s3_bucket_arn
      file_key   = var.s3_file_key
    }
  }

  tags = merge(
    local.tags,
    { Name = local.connector_name }
  )
}