################################################################################
# Cluster
################################################################################

output "arn" {
  description = "Amazon Resource Name (ARN) of the MSK cluster"
  value = try(aws_msk_cluster.this[0].arn, null)
}

output "cluster_name" {
  description = "Name of the MSK cluster"
  value = try(aws_msk_cluster.this[0].cluster_name, null)
}

output "cluster_uuid" {
  description = "UUID of the MSK cluster, for use in IAM policies"
  value = try(aws_msk_cluster.this[0].cluster_uuid, null)
}

output "bootstrap_brokers" {
  description = "Comma separated list of one or more hostname:port pairs of kafka brokers suitable to bootstrap connectivity to the kafka cluster"
  value = sort(compact([
    try(aws_msk_cluster.this[0].bootstrap_brokers, null),
    try(aws_msk_cluster.this[0].bootstrap_brokers_sasl_iam, null),
    try(aws_msk_cluster.this[0].bootstrap_brokers_sasl_scram, null),
    try(aws_msk_cluster.this[0].bootstrap_brokers_tls, null),
  ]))
}

output "bootstrap_brokers_plaintext" {
  description = "Comma separated list of one or more hostname:port pairs of kafka brokers suitable to bootstrap connectivity to the kafka cluster. Contains a value if `encryption_in_transit_client_broker` is set to `PLAINTEXT` or `TLS_PLAINTEXT`"
  value = try(aws_msk_cluster.this[0].bootstrap_brokers, null)
}

output "bootstrap_brokers_sasl_iam" {
  description = "One or more DNS names (or IP addresses) and SASL IAM port pairs. This attribute will have a value if `encryption_in_transit_client_broker` is set to `TLS_PLAINTEXT` or `TLS` and `client_authentication_sasl_iam` is set to `true`"
  value = try(aws_msk_cluster.this[0].bootstrap_brokers_sasl_iam, null)
}

output "bootstrap_brokers_sasl_scram" {
  description = "One or more DNS names (or IP addresses) and SASL SCRAM port pairs. This attribute will have a value if `encryption_in_transit_client_broker` is set to `TLS_PLAINTEXT` or `TLS` and `client_authentication_sasl_scram` is set to `true`"
  value = try(aws_msk_cluster.this[0].bootstrap_brokers_sasl_scram, null)
}

output "bootstrap_brokers_tls" {
  description = "One or more DNS names (or IP addresses) and TLS port pairs. This attribute will have a value if `encryption_in_transit_client_broker` is set to `TLS_PLAINTEXT` or `TLS`"
  value = try(aws_msk_cluster.this[0].bootstrap_brokers_tls, null)
}

output "bootstrap_brokers_authentication" {
  description = "Name string of brokers authentication for client."
  value = var.enable_client_auth_iam ? "SASL_IAM" : var.enable_client_auth_scram ? "SASL_SCRAM" : "TLS"
}

output "zookeeper_connect_string" {
  description = "A comma separated list of one or more hostname:port pairs to use to connect to the Apache Zookeeper cluster. The returned values are sorted alphabetically"
  value = try(aws_msk_cluster.this[0].zookeeper_connect_string, null)
}

output "zookeeper_connect_string_tls" {
  description = "A comma separated list of one or more hostname:port pairs to use to connect to the Apache Zookeeper cluster via TLS. The returned values are sorted alphabetically"
  value = try(aws_msk_cluster.this[0].zookeeper_connect_string_tls, null)
}

################################################################################
# Configuration
################################################################################

output "configuration_arn" {
  description = "Amazon Resource Name (ARN) of the configuration"
  value = try(aws_msk_configuration.this[0].arn, null)
}

output "configuration_latest_revision" {
  description = "Latest revision of the configuration"
  value = try(aws_msk_configuration.this[0].latest_revision, null)
}

################################################################################
# Secret(s)
################################################################################

output "scram_secret_association_id" {
  description = "Amazon Resource Name (ARN) of the MSK cluster"
  value = try(aws_msk_scram_secret_association.this[0].id, null)
}

################################################################################
# CloudWatch Log Group
################################################################################

output "log_group_arn" {
  description = "The Amazon Resource Name (ARN) specifying the log group"
  value = try(aws_cloudwatch_log_group.cwLog[0].arn, null)
}

################################################################################
# Storage Autoscaling
################################################################################

output "appautoscaling_policy_arn" {
  description = "The ARN assigned by AWS to the scaling policy"
  value = try(aws_appautoscaling_policy.this[0].arn, null)
}

output "appautoscaling_policy_name" {
  description = "The scaling policy's name"
  value = try(aws_appautoscaling_policy.this[0].name, null)
}

output "appautoscaling_policy_policy_type" {
  description = "The scaling policy's type"
  value = try(aws_appautoscaling_policy.this[0].policy_type, null)
}