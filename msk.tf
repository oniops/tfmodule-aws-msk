locals {
  project           = var.context.project
  account_id        = var.context.account_id
  name_prefix       = var.context.name_prefix
  tags              = var.context.tags
  is_broker_express = var.instance_type != null ? (split(".", var.instance_type)[0] == "express" ? true : false) : false
  cluster_name      = var.cluster_fullname != null ? var.cluster_fullname : "${local.name_prefix}-${var.cluster_name}-msk"
}

################################################################################
# Cluster
################################################################################

resource "aws_msk_cluster" "this" {
  count = var.create && !var.enable_serverless_cluster ? 1 : 0

  cluster_name           = local.cluster_name
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.number_of_broker_nodes
  storage_mode           = local.is_broker_express ? null : var.storage_mode

  broker_node_group_info {
    instance_type   = var.instance_type
    az_distribution = "DEFAULT"
    client_subnets  = var.client_subnets
    security_groups = var.security_groups

    connectivity_info {
      public_access {
        type = var.public_access_type
      }

      dynamic "vpc_connectivity" {
        for_each = var.enable_vpc_connectivity ? [true] : []
        content {
          client_authentication {
            tls = var.vpc_connectivity_auth_tls
            sasl {
              iam = var.vpc_connectivity_auth_iam
              scram = var.vpc_connectivity_auth_scram
            }
          }
        }
      }
    }

    dynamic "storage_info" {
      for_each = local.is_broker_express ? [] : [true]
      content {
        ebs_storage_info {
          volume_size = var.ebs_volume_size
          dynamic "provisioned_throughput" {
            for_each = var.enable_provisioned_throughput ? [true] : []
            content {
              enabled           = var.enable_provisioned_throughput
              volume_throughput = var.provisioned_volume_throughput
            }
          }
        }
      }
    }
  }

  client_authentication {
    unauthenticated = var.enable_client_noauth
    dynamic "tls" {
      for_each = var.client_auth_cert_authority_arns != null ? [true] : []
      content {
        certificate_authority_arns = var.client_auth_cert_authority_arns
      }
    }
    sasl {
      iam   = var.enable_client_auth_iam
      scram = var.enable_client_auth_scram
    }
  }

  configuration_info {
    arn      = var.create_configuration ? aws_msk_configuration.this[0].arn : var.configuration_arn
    revision = var.create_configuration ? aws_msk_configuration.this[0].latest_revision : var.configuration_revision
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = var.encryption_at_rest_kms_key_arn

    encryption_in_transit {
      client_broker = var.encryption_in_transit_client_broker
      in_cluster    = var.encryption_in_transit_in_cluster
    }
  }

  enhanced_monitoring = var.enhanced_monitoring

  dynamic "logging_info" {
    for_each = local.is_broker_express ? [] : [true]
    content {
      broker_logs {
        cloudwatch_logs {
          enabled   = var.cloudwatch_logs_enabled
          log_group = var.cloudwatch_logs_enabled ? local.cloudwatch_log_group_name : null
        }

        firehose {
          enabled         = var.firehose_logs_enabled
          delivery_stream = var.firehose_delivery_stream
        }

        s3 {
          bucket  = var.s3_logs_bucket
          enabled = var.s3_logs_enabled
          prefix  = var.s3_logs_prefix
        }
      }
    }
  }

  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = var.jmx_exporter_enabled
      }
      node_exporter {
        enabled_in_broker = var.node_exporter_enabled
      }
    }
  }

  # required for appautoscaling
  lifecycle {
    ignore_changes = [
      broker_node_group_info[0].storage_info[0],
    ]
  }

  tags = merge(local.tags,
    var.cluster_tags, {
      Name = local.cluster_name
    })

  depends_on = [
    aws_cloudwatch_log_group.cwLog[0]
  ]
}

resource "aws_msk_serverless_cluster" "this" {
  count = var.create && var.enable_serverless_cluster ? 1 : 0

  cluster_name = local.cluster_name
  vpc_config {
    subnet_ids         = var.client_subnets
    security_group_ids = var.security_groups
  }

  client_authentication {
    sasl {
      iam {
        enabled = var.enable_client_auth_iam
      }
    }
  }

  tags = merge(local.tags,
    var.cluster_tags, {
      Name = local.cluster_name
    })

  depends_on = [
    aws_cloudwatch_log_group.cwLog[0]
  ]
}

################################################################################
# Configuration
################################################################################

resource "aws_msk_configuration" "this" {
  count = var.create && var.create_configuration ? 1 : 0

  name = var.configuration_name != null ? var.configuration_name : "${local.name_prefix}-${var.cluster_name}-mskcfg"
  description    = var.configuration_description
  kafka_versions = var.configuration_kafka_versions
  server_properties = join("\n", [
    for k, v in var.configuration_server_properties : "${k} = ${v}"
  ])

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# Secret(s)
################################################################################

resource "aws_msk_scram_secret_association" "this" {
  count = var.create && var.create_scram_secret_association && length(var.scram_secret_list) != 0 ? 1 : 0

  cluster_arn     = aws_msk_cluster.this[0].arn
  secret_arn_list = var.scram_secret_list

  depends_on = [
    aws_msk_cluster.this
  ]
}

################################################################################
# Storage Autoscaling
################################################################################

resource "aws_appautoscaling_target" "this" {
  count = var.create && var.enable_storage_autoscaling ? 1 : 0

  max_capacity = var.scaling_max_size
  min_capacity = 1 # EBS Stroage autoscaling은 scale-in을 지원하지 않으나 필수 속성으로 추가한 값임.
  role_arn     = "arn:aws:iam::${local.account_id}:role/aws-service-role/kafka.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_KafkaCluster"
  resource_id  = aws_msk_cluster.this[
  0
  ].arn
  scalable_dimension = "kafka:broker-storage:VolumeSize"
  service_namespace  = "kafka"

  tags = var.tags
}

resource "aws_appautoscaling_policy" "this" {
  count = var.create && var.enable_storage_autoscaling ? 1 : 0

  name               = "${local.name_prefix}-${var.cluster_name}-msk-storage-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_msk_cluster.this[0].arn
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "KafkaBrokerStorageUtilization"
    }

    target_value = var.scaling_target_value
  }
}

