locals {
  name_prefix     = var.context.name_prefix
  region          = var.context.region
  account_id      = var.context.account_id
  project         = var.context.project
  tags            = var.context.tags
  replicator_name = var.replicator_fullname != null ? var.replicator_fullname : "${local.name_prefix}-${var.replicator_name}-rc"
  description     = var.description != null ? var.description : local.replicator_name
}

################################################################################
# Replicators
################################################################################

resource "aws_msk_replicator" "this" {
  count                      = var.create ? 1 : 0
  replicator_name            = local.replicator_name
  description                = local.description
  service_execution_role_arn = aws_iam_role.this[0].arn

  kafka_cluster {
    amazon_msk_cluster {
      msk_cluster_arn = var.source_msk_cluster_arn
    }

    vpc_config {
      subnet_ids          = var.source_msk_cluster_subnet_ids
      security_groups_ids = var.source_msk_cluster_security_groups_ids
    }
  }

  kafka_cluster {
    amazon_msk_cluster {
      msk_cluster_arn = var.target_msk_cluster_arn
    }

    vpc_config {
      subnet_ids          = var.target_msk_cluster_subnet_ids
      security_groups_ids = var.target_msk_cluster_security_groups_ids
    }
  }

  replication_info_list {
    source_kafka_cluster_arn = var.source_msk_cluster_arn
    target_kafka_cluster_arn = var.target_msk_cluster_arn
    target_compression_type  = var.target_compression_type

    topic_replication {
      topics_to_replicate                  = var.topics_to_replicate
      topics_to_exclude                    = var.topics_to_exclude
      detect_and_copy_new_topics           = var.detect_and_copy_new_topics
      copy_topic_configurations            = var.copy_topic_configurations
      copy_access_control_lists_for_topics = var.copy_access_control_lists_for_topics

      topic_name_configuration {
        type = var.topic_name_configuration
      }

      starting_position {
        type = var.starting_position
      }
    }

    consumer_group_replication {
      consumer_groups_to_replicate        = var.consumer_groups_to_replicate
      consumer_groups_to_exclude          = var.consumer_groups_to_exclude
      detect_and_copy_new_consumer_groups = var.detect_and_copy_new_consumer_groups
      synchronise_consumer_group_offsets  = var.synchronise_consumer_group_offsets
    }
  }

  timeouts {
    create = "1h"
    update = "1h"
    delete = "1h"
  }

  tags = merge(local.tags,
    var.replicator_tags, {
      Name = local.replicator_name
    })

  depends_on = [
    aws_iam_role.this
  ]
}