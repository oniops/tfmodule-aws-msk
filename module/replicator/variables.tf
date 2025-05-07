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
# Replicator
################################################################################
variable "replicator_name" {
  type        = string
  default     = null
  description = "The name of the replicator"
}

variable "replicator_fullname" {
  type        = string
  default     = null
  description = "The full name of the replicator"
}

variable "description" {
  type        = string
  default     = null
  description = "A summary description of the replicator"
}

variable "source_msk_cluster_name" {
  type        = string
  description = "The name of the source MSK cluster"
}

variable "source_msk_cluster_arn" {
  type        = string
  description = "The ARN of the source MSK cluster"
}

variable "source_msk_cluster_subnet_ids" {
  type = list(string)
  description = "The list of source MSK cluster subnets to connect to in the virtual private cloud (VPC). AWS creates elastic network interfaces inside these subnets to allow communication between your MSK Cluster and the replicator"
}

variable "source_msk_cluster_security_groups_ids" {
  type = list(string)
  description = "The source MSK cluster security groups to associate with the ENIs used by the replicator. If a security group is not specified, the default security group associated with the VPC is used"
}

variable "target_msk_cluster_arn" {
  type        = string
  description = "The ARN of the target MSK cluster"
}

variable "target_msk_cluster_name" {
  type        = string
  description = "The name of the target MSK cluster"
}

variable "target_msk_cluster_subnet_ids" {
  type = list(string)
  description = "The list of target MSK cluster subnets to connect to in the virtual private cloud (VPC). AWS creates elastic network interfaces inside these subnets to allow communication between your MSK Cluster and the replicator"
}

variable "target_msk_cluster_security_groups_ids" {
  type = list(string)
  description = "The target MSK cluster security groups to associate with the ENIs used by the replicator. If a security group is not specified, the default security group associated with the VPC is used"
}

variable "target_compression_type" {
  type        = string
  default     = "NONE"
  description = "The type of compression to use writing records to target MSK cluster. Available options are NONE | GZIP | SNAPPY | LZ4 | ZSTD"
}

variable "topic_name_configuration" {
  type        = string
  default     = "PREFIXED_WITH_SOURCE_CLUSTER_ALIAS"
  description = "Configuration for specifying replicated topic names should be the same as their corresponding upstream topics or prefixed with source cluster alias. Available options are PREFIXED_WITH_SOURCE_CLUSTER_ALIAS | IDENTICAL"
}

variable "topics_to_replicate" {
  type = list(string)
  default = [".*"]
  description = "List of regular expression patterns indicating the topics to copy"
}

variable "topics_to_exclude" {
  type = list(string)
  default     = null
  description = "List of regular expression patterns indicating the topics that should not be replica"
}

variable "detect_and_copy_new_topics" {
  type        = bool
  default     = true
  description = "Whether to periodically check for new topics and partitions"
}

variable "copy_access_control_lists_for_topics" {
  type        = bool
  default     = true
  description = "Whether to periodically configure remote topic ACLs to match their corresponding upstream topics"
}

variable "copy_topic_configurations" {
  type        = bool
  default     = true
  description = "Whether to periodically configure remote topics to match their corresponding upstream topics"
}

variable "starting_position" {
  type        = string
  default     = "LATEST"
  description = "Configuration for specifying the position in the topics to start replicating from. Available options are LATEST | EARLIEST"
}

variable "consumer_groups_to_replicate" {
  type = list(string)
  default = [".*"]
  description = "List of regular expression patterns indicating the consumer groups to copy."
}

variable "consumer_groups_to_exclude" {
  type = list(string)
  default     = null
  description = "List of regular expression patterns indicating the consumer groups that should not be replicated."
}

variable "detect_and_copy_new_consumer_groups" {
  type        = bool
  default     = true
  description = "Whether to periodically check for new consumer groups."
}

variable "synchronise_consumer_group_offsets" {
  type        = bool
  default     = true
  description = "Whether to periodically write the translated offsets to __consumer_offsets topic in target cluster."
}