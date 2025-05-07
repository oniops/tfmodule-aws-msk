variable "context" {
  description = "Specify context values. This module uses the tfmodule-context Terraform module to define MSK services and resources, providing a standardized naming policy and tagging conventions, and a consistent datasource reference module. For more information about Context, see the https://github.com/oniops/tfmodule-context Terraform module."
  type = any
}

variable "create" {
  description = "Determines whether cluster resources will be created"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the resources created"
  type = map(string)
  default = {}
}

variable "additional_tags" {
  description = "Specify additional tags for resources created in this module"
  type = map(string)
  default = {}
}


################################################################################
# Cluster
################################################################################

variable "enable_serverless_cluster" {
  description = "Whether enable or not serverless type of broker. default : not use (provisioned)"
  default     = false
}

variable "client_subnets" {
  description = "A list of subnets to connect to in client VPC ([documentation](https://docs.aws.amazon.com/msk/1.0/apireference/clusters.html#clusters-prop-brokernodegroupinfo-clientsubnets))"
  type = list(string)
}

variable "public_access_type" {
  description = <<EOF
Allow or not access from public to broker.
Usage : DISABLED | SERVICE_PROVIDED_EIPS
DISABLED means that public access is turned off. SERVICE_PROVIDED_EIPS means that public access is turned on.
EOF
  type        = string
  default     = "DISABLED"
}

variable "instance_type" {
  description = "Specify the instance type to use for the kafka brokers. e.g. kafka.m5.large. ([Pricing info](https://aws.amazon.com/msk/pricing/))"
  type        = string
  default     = null
}

variable "security_groups" {
  description = "A list of the security groups to associate with the elastic network interfaces to control who can communicate with the cluster"
  type = list(string)
  default = []
}

variable "ebs_volume_size" {
  description = "EBS Storage volumes size attached to MSK broker nodes. min: 1, max: 16384, unit: GiB"
  type        = number
  default     = 1000
}

variable "enable_provisioned_throughput" {
  description = "Provisioned throughput is enabled or not."
  type        = bool
  default     = false
}

variable "provisioned_volume_throughput" {
  description = "Throughput value of the EBS volumes for the data drive on each kafka broker node in MiB per second."
  type        = number
  default     = 250
}

variable "enable_client_noauth" {
  description = "Allow or not client access without authentication"
  type        = bool
  default     = false
}

variable "enable_client_auth_iam" {
  description = "SASL/IAM authentication is enabled or not."
  type        = bool
  default     = false
}

variable "enable_client_auth_scram" {
  description = "SASL/SCRAM authentication is enabled or not."
  type        = bool
  default     = false
}

variable "client_auth_cert_authority_arns" {
  description = "List of AWS Private CA Amazon Resource Name (ARN)s. If listed, client checks broker's certificates"
  type = list(string)
  default     = null
}

variable "cluster_name" {
  description = "Name of the MSK cluster"
  type        = string
}

variable "cluster_fullname" {
  description = "Fullname of the MSK cluster"
  type        = string
  default     = null
}

variable "encryption_at_rest_kms_key_arn" {
  description = "You may specify a KMS key short ID or ARN (it will always output an ARN) to use for encrypting your data at rest. If no key is specified, an AWS managed KMS ('aws/msk' managed service) key will be used for encrypting the data at rest"
  type        = string
  default     = null
}

variable "encryption_in_transit_client_broker" {
  description = "Encryption setting for data in transit between clients and brokers. Valid values: `TLS`, `TLS_PLAINTEXT`, and `PLAINTEXT`. Default value is `TLS`"
  type        = string
  default     = "TLS"
}

variable "encryption_in_transit_in_cluster" {
  description = "Whether data communication among broker nodes is encrypted. Default value: `true`"
  type        = bool
  default     = true
}

variable "enhanced_monitoring" {
  description = "Specify the desired enhanced MSK CloudWatch monitoring level. Available options are DEFAULT | PER_BROKER | PER_TOPIC_PER_BROKER | PER_TOPIC_PER_PARTITION. See [Monitoring Amazon MSK with Amazon CloudWatch](https://docs.aws.amazon.com/msk/latest/developerguide/monitoring.html)"
  type        = string
  default     = null
}

variable "kafka_version" {
  description = "Specify the desired Kafka software version"
  type        = string
  default     = null
}

variable "cloudwatch_log_group_class" {
  description = "Specifies the log class of the log group. Possible values are: STANDARD or INFREQUENT_ACCESS."
  type        = string
  default     = null
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

variable "number_of_broker_nodes" {
  description = "The desired total number of broker nodes in the kafka cluster. It must be a multiple of the number of specified client subnets"
  type        = number
  default     = null
}

variable "jmx_exporter_enabled" {
  description = "Indicates whether you want to enable or disable the JMX Exporter"
  type        = bool
  default     = false
}

variable "node_exporter_enabled" {
  description = "Indicates whether you want to enable or disable the Node Exporter"
  type        = bool
  default     = false
}

variable "storage_mode" {
  description = "Controls storage mode for supported storage tiers. Valid values are: `LOCAL` or `TIERED`"
  type        = string
  default     = "LOCAL"
}

variable "enable_vpc_connectivity" {
  description = "Whether to use multiple VPC Connection. See https://docs.aws.amazon.com/msk/latest/developerguide/aws-access-mult-vpc.html"
  type        = bool
  default     = false
}

variable "vpc_connectivity_auth_tls" {
  description = "Enables TLS authentication for VPC connectivity"
  type        = bool
  default     = false
}

variable "vpc_connectivity_auth_iam" {
  description = "Enables SASL/IAM authentication for VPC connectivity"
  type        = bool
  default     = false
}

variable "vpc_connectivity_auth_scram" {
  description = "Enables SASL/SCRAM authentication for VPC connectivity"
  type        = bool
  default     = false
}

################################################################################
# Configuration
################################################################################

variable "create_configuration" {
  description = "Determines whether to create a configuration"
  type        = bool
  default     = true
}

variable "configuration_arn" {
  description = "ARN of an externally created configuration to use"
  type        = string
  default     = null
}

variable "configuration_name" {
  description = "Specify cluster configuration name"
  type        = string
  default     = null
}

variable "configuration_revision" {
  description = "Revision of the externally created configuration to use"
  type        = number
  default     = null
}

variable "configuration_description" {
  description = "Description of the configuration"
  type        = string
  default     = null
}

variable "configuration_kafka_versions" {
  description = "Support Kafka version"
  type = list(string)
  default     = null
}

variable "configuration_server_properties" {
  description = <<EOF
Contents of the server.properties file. Supported properties are documented in the [MSK Developer Guide](https://docs.aws.amazon.com/msk/latest/developerguide/msk-configuration-properties.html)
For example)
  configuration_server_properties = {
    "auto.create.topics.enable"      = true
    "delete.topic.enable"            = true
    "default.replication.factor"     = 2
    "min.insync.replicas"            = 2
    "num.io.threads"                 = 8
    "num.network.threads"            = 5
    "num.partitions"                 = 2
    "num.replica.fetchers"           = 2
    "replica.lag.time.max.ms"        = 30000
    "socket.receive.buffer.bytes"    = 102400
    "socket.request.max.bytes"       = 104857600
    "socket.send.buffer.bytes"       = 102400
    "unclean.leader.election.enable" = false
    "zookeeper.session.timeout.ms"   = 18000
    "allow.everyone.if.no.acl.found" = false
  }
EOF
  type = map(string)
  default = {}
}

################################################################################
# Secret(s)
################################################################################

variable "create_scram_secret_association" {
  description = "Determines whether to create SASL/SCRAM secret association"
  type        = bool
  default     = false
}

variable "scram_secret_list" {
  description = "List of AWS Secrets Manager secret ARNs to associate with SCRAM"
  type = list(string)
  default = []
}

################################################################################
# CloudWatch Log Group
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

################################################################################
# Storage Autoscaling
################################################################################
variable "enable_storage_autoscaling" {
  description = "Determines whether autoscaling is enabled for storage"
  type        = bool
  default     = false
}

variable "scaling_max_size" {
  description = "Max storage size for Kafka broker autoscaling"
  type        = number
  default     = 250
}

variable "scaling_target_value" {
  description = "The Kafka broker storage utilization at which scaling is initiated"
  type        = number
  default     = 70
}