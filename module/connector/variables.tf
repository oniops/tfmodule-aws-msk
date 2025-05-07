variable "context" {
  description = "Specify context values. This module uses the tfmodule-context Terraform module to define MSK services and resources, providing a standardized naming policy and tagging conventions, and a consistent datasource reference module. For more information about Context, see the https://github.com/oniops/tfmodule-context Terraform module."
  type = any
}

variable "create" {
  description = "Determines whether cluster will be created"
  type        = bool
  default     = true
}

variable "additional_tags" {
  description = "Specify additional tags for resources created in this module"
  type = map(string)
  default = {}
}

################################################################################
# Connector Variables
################################################################################

variable "create_connector_role" {
  description = "Determines whether Connect role will be created"
  type        = bool
  default     = true
}

variable "service_exec_role_arn" {
  description = "The Amazon Resource Name (ARN) of the IAM role used by the connector to access the Amazon Web Services resources that it needs. The types of resources depends on the logic of the connector. For example, a connector that has Amazon S3 as a destination must have permissions that allow it to write to the S3 destination bucket."
  type        = string
  default     = null
}

variable "service_exec_role_path" {
  description = "Connector Service Execution role path"
  type        = string
  default     = null
}

variable "service_exec_role_description" {
  description = "Description of the Connector Service Execution role"
  type        = string
  default     = null
}

variable "service_exec_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the Connector Service Execution IAM role"
  type        = string
  default     = null
}

variable "service_exec_role_additional_policies" {
  description = <<EOF
Additional policies to be added to the Connector Service Execution IAM role
ex)
  service_exec_role_additional_policies = {
    "AAA_Policy" = "AAA_POLICY_ARN",
    "BBB_Policy" = "BBB_POLICY_ARN"
  }
EOF
  type        = map(string)
  default     = {}
}


variable "connector_description" {
  description = "A description of the resource or configuration. Optional."
  type        = string
  default     = null
}

variable "connector_name" {
  description = "The name of the connector"
  type        = string
  default     = null
}

variable "connector_fullname" {
  description = "The name of the connector"
  type        = string
  default     = null
}

variable "kafkaconnect_version" {
  description = "Specify the desired Kafka software version"
  type        = string
  default     = null
}

variable "enable_autoscaling" {
  description = "Indicates whether autoscaling is enabled."
  type        = bool
  default     = false
}

variable "autoscaling_mcu_count" {
  description = "The number of MCUs to allocate for provisioned capacity."
  type        = number
  default     = 1
}

variable "autoscaling_min_worker_count" {
  description = "The minimum number of workers for autoscaling."
  type        = number
  default     = 1
}

variable "autoscaling_max_worker_count" {
  description = "The maximum number of workers for autoscaling."
  type        = number
  default     = 2
}

variable "scale_in_cpu_utilization_percentage" {
  description = "CPU utilization percentage threshold for scaling in."
  type        = number
  default     = 20
}

variable "scale_out_cpu_utilization_percentage" {
  description = "CPU utilization percentage threshold for scaling out."
  type        = number
  default     = 80
}

variable "provisioned_capacity_mcu_count" {
  description = "The number of MCUs to allocate for provisioned capacity."
  type        = number
  default     = 1
}

variable "provisioned_capacity_worker_count" {
  description = "The number of workers to allocate for provisioned capacity."
  type        = number
  default     = 1
}

variable "connector_configuration" {
  type        = map(string)
  description = <<EOF
A map of keys to values that represent the configuration for the connector.

connector_configuration = {
  "connector.class"       = "io.debezium.connector.jdbc.JdbcSinkConnector"
  "tasks.max"             = "1"
}
EOF
}

variable "cluster_name" {
  description = "Kafka Cluster(MSK) Name"
  type = string
}

variable "bootstrap_servers" {
  description = "A comma-listed-string of broker endpoints of Kafka Cluster."
  type = string
}

variable "subnet_ids" {
  description = "A list of subnets of Kafka Cluster."
  type = list(string)
}

variable "security_groups" {
  description = "A list of security groups of Kafka Cluster."
  type = list(string)
}

variable "encryption_type" {
  description = "Encryption settings for Kafka cluster in transit. Choose either TLS or PLAINTEXT."
  type        = string
  default     = "TLS"
}

variable "authentication_type" {
  description = "Client authentication settings for Kafka cluster. Choose either IAM or NONE."
  type        = string
  default     = "IAM"
}

variable "cloudwatch_logs_enabled" {
  description = "Indicates whether you want to enable or disable streaming broker logs to Cloudwatch Logs"
  type        = bool
  default     = true
}

variable "firehose_logs_enabled" {
  description = "Indicates whether you want to enable or disable streaming broker logs to Kinesis Data Firehose"
  type        = bool
  default     = false
}

variable "firehose_delivery_stream" {
  description = "Name of the Kinesis Data Firehose delivery stream to deliver logs to"
  type        = string
  default     = null
}

variable "s3_logs_enabled" {
  description = "Indicates whether you want to enable or disable streaming broker logs to S3"
  type        = bool
  default     = false
}

variable "s3_logs_bucket" {
  description = "Name of the S3 bucket to deliver logs to"
  type        = string
  default     = null
}

variable "s3_logs_prefix" {
  description = "Prefix to append to the folder name"
  type        = string
  default     = null
}

################################################################################
# CloudWatch Log Group Variables
################################################################################

variable "create_cloudwatch_log_group" {
  description = "Determines whether to create a CloudWatch log group"
  type        = bool
  default     = true
}

variable "cloudwatch_log_group_name" {
  description = "Name of the Cloudwatch Log Group to deliver logs to"
  type        = string
  default     = null
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the log group"
  type        = number
  default     = 14
}

variable "cloudwatch_log_group_kms_key_id" {
  description = "The ARN of the KMS Key to use when encrypting log data"
  type        = string
  default     = null
}

variable "cloudwatch_log_group_class" {
  description = "Specifies the log class of the log group. Possible values are: STANDARD or INFREQUENT_ACCESS."
  type        = string
  default     = null
}

################################################################################
# Worker Configuration Variables
################################################################################

variable "create_worker_configuration" {
  description = "Determines whether to create connect worker configuration"
  type        = bool
  default     = true
}

variable "worker_configuration_name" {
  description = "The name of the worker configuration"
  type        = string
  default     = null
}

variable "worker_configuration_fullname" {
  description = "The name of the worker configuration"
  type        = string
  default     = null
}

variable "worker_configuration_description" {
  description = "A summary description of the worker configuration"
  type        = string
  default     = null
}

variable "properties_file_content" {
  type        = map(string)
  description = <<EOF
These are the settings for configuring workers in MSK Connect. These settings determine how the workers operate, how they transform data, and how they communicate with the Kafka cluster.

worker_properties_file_content = {
  "key.converter"                                = "org.apache.kafka.connect.json.JsonConverter"
  "value.converter"                              = "org.apache.kafka.connect.json.JsonConverter"
  "key.converter.schemas.enable"                 = false
  "value.converter.schemas.enable"               = true
}
EOF
}

################################################################################
# Plugin Variables
################################################################################

variable "plugin_name" {
  description = "The name of the custom plugin to be used with MSK Connect."
  type        = string
  default     = null
}

variable "plugin_fullname" {
  description = "The full name of the plugin, which may include additional details like versioning or full description."
  type        = string
  default     = null
}

variable "plugin_description" {
  description = "A textual description of the custom plugin being created."
  type        = string
  default     = null
}

variable "content_type" {
  description = "Specifies the content type of the plugin file (e.g., ZIP or JAR)."
  type        = string
  default     = "ZIP"
}

variable "s3_bucket_arn" {
  description = "The Amazon Resource Name (ARN) of the S3 bucket where the plugin content is stored."
  type        = string
}

variable "s3_file_key" {
  description = "The key (path) to the specific file within the S3 bucket that contains the plugin."
  type        = string
}

variable "plugin_arn" {
  description = "The Amazon Resource Name (ARN) of the custom plugin."
  type        = string
  default     = null
}

variable "plugin_revision" {
  description = "The specific revision or version identifier of the custom plugin to be used."
  type        = string
  default     = null
}

variable "worker_configuration_arn" {
  description = "The Amazon Resource Name (ARN) of the custom plugin."
  type        = string
  default     = null
}

variable "worker_configuration_revision" {
  description = "The specific revision or version identifier of the custom plugin to be used."
  type        = string
  default     = null
}


