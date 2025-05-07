################################################################################
# Managed VPC connection
################################################################################

output "arn" {
  description = "Amazon Resource Name (ARN) of the Managed VPC connection"
  value = try(aws_msk_vpc_connection.this[0].arn, null)
}