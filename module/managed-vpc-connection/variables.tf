variable "context" {
  description = "Specify context values. This module uses the tfmodule-context Terraform module to define MSK services and resources, providing a standardized naming policy and tagging conventions, and a consistent datasource reference module. For more information about Context, see the https://github.com/oniops/tfmodule-context Terraform module."
  type = any
}

variable "create" {
  description = "Determines whether replicator resources will be created"
  type        = bool
  default     = true
}

variable "additional_tags" {
  description = "Specify additional tags for resources created in this module"
  type = map(string)
  default = {}
}

################################################################################
# Managed VPC Connections
################################################################################
variable "authentication" {
  type        = string
  default     = "SASL_IAM"
  description = "The authentication type for the client VPC connection. Specify one of these auth type strings: SASL_IAM, SASL_SCRAM, or TLS."
}

variable "target_cluster_arn" {
  type        = string
  description = "The Amazon Resource Name (ARN) of the cluster."
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID of the remote client."
}

variable "client_subnets" {
  type        = list(string)
  description = "The list of subnets in the client VPC to connect to."
}

variable "security_groups" {
  type        = list(string)
  description = "The security groups to attach to the ENIs for the broker nodes."
}