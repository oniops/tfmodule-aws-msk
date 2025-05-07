################################################################################
# MSK Connector
################################################################################

output "arn" {
  description = "Amazon Resource Name (ARN) of the MSK Connector"
  value = try(aws_mskconnect_connector.this[0].arn, null)
}

output "custom_plugin_arn" {
  description = "Amazon Resource Name (ARN) of the Custom plugin"
  value = try(aws_mskconnect_custom_plugin.this[0].arn, null)
}

output "aws_mskconnect_worker_configuration" {
  description = "Amazon Resource Name (ARN) of the Worker configuration"
  value = try(aws_mskconnect_worker_configuration.this[0].arn, null)
}