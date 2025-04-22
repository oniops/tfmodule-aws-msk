variable "create" {
  description = "Determines whether replicator resources will be created"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the resources created"
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