locals {
  create      = var.create
  project     = var.context.project
  region      = var.context.region
  tags        = merge(var.context.tags, var.additional_tags)
  account_id  = var.context.account_id
  name_prefix = var.context.name_prefix

  cluster_name      = var.cluster_name
  bootstrap_servers = var.bootstrap_servers
  subnet_ids        = var.subnet_ids
  security_groups   = var.security_groups

  // @formatter:off
  connector_name             = var.connector_fullname != null ? var.connector_fullname : "${local.name_prefix}-${var.connector_name}-connector"
  // @formatter:on
}

resource "aws_mskconnect_connector" "this" {
  count                      = local.create ? 1 : 0
  name                       = local.connector_name
  description                = var.connector_description
  kafkaconnect_version       = var.kafkaconnect_version
  connector_configuration    = var.connector_configuration
  service_execution_role_arn = local.service_exec_role_arn

  capacity {
    dynamic "provisioned_capacity" {
      for_each = var.enable_autoscaling ? [] : [1]
      content {
        mcu_count    = var.provisioned_capacity_mcu_count
        worker_count = var.provisioned_capacity_worker_count
      }
    }

    dynamic "autoscaling" {
      for_each = var.enable_autoscaling ? [1] : []
      content {
        mcu_count        = var.autoscaling_mcu_count
        min_worker_count = var.autoscaling_min_worker_count
        max_worker_count = var.autoscaling_max_worker_count

        scale_in_policy {
          cpu_utilization_percentage = var.scale_in_cpu_utilization_percentage
        }

        scale_out_policy {
          cpu_utilization_percentage = var.scale_out_cpu_utilization_percentage
        }
      }
    }
  }

  kafka_cluster {
    apache_kafka_cluster {
      bootstrap_servers = local.bootstrap_servers
      vpc {
        security_groups = local.security_groups
        subnets         = local.subnet_ids
      }
    }
  }

  kafka_cluster_client_authentication {
    authentication_type = var.authentication_type
  }

  kafka_cluster_encryption_in_transit {
    encryption_type = var.encryption_type
  }

  plugin {
    custom_plugin {
      arn      = local.plugin_arn
      revision = local.plugin_revision
    }
  }

  worker_configuration {
    arn      = local.worker_configuration_arn
    revision = local.worker_configuration_revision
  }

  log_delivery {
    worker_log_delivery {
      cloudwatch_logs {
        enabled   = var.cloudwatch_logs_enabled
        log_group = local.cloudwatch_log_group_name
      }

      firehose {
        enabled         = var.firehose_logs_enabled
        delivery_stream = var.firehose_delivery_stream
      }

      s3 {
        enabled = var.s3_logs_enabled
        bucket  = var.s3_logs_bucket
        prefix  = var.s3_logs_prefix
      }
    }
  }

  tags = merge(
    local.tags,
    { Name = local.connector_name }
  )

  depends_on = [
    aws_cloudwatch_log_group.cwLog[0],
    aws_iam_role.this[0],
    aws_mskconnect_custom_plugin.this[0],
    aws_mskconnect_worker_configuration.this[0]
  ]
}



