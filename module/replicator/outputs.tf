################################################################################
# Replicator
################################################################################

output "arn" {
  description = "Amazon Resource Name (ARN) of the MSK Replicator"
  value = try(aws_msk_replicator.this[0].arn, null)
}