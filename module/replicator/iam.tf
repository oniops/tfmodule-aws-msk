locals {
  name_prefix_iam = "${local.project}${replace(title(var.replicator_name), "-", "")}"
  role_name       = "${local.name_prefix_iam}MskReplicatorServiceExecRole"

  trust = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "MSKReplicatorAssumeRole",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : [
            "kafka.amazonaws.com"
          ]
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role" "this" {
  count                 = var.create ? 1 : 0
  name                  = local.role_name
  description           = "Service execution role for MSK replicator ${local.replicator_name}"
  assume_role_policy    = local.trust
  force_detach_policies = true

  tags = merge(
    local.tags,
    { Name = local.role_name }
  )
}

resource "aws_iam_role_policy" "this" {
  count = var.create ? 1 : 0
  name  = "${local.name_prefix_iam}MskReplicatorServiceExecPolicy"
  role  = aws_iam_role.this[0].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowClusterConnect"
        Effect = "Allow"
        Action = [
          "kafka-cluster:Connect",
          "kafka-cluster:DescribeCluster",
          "kafka-cluster:WriteDataIdempotently"
        ]
        Resource = [
          var.source_msk_cluster_arn,
          var.target_msk_cluster_arn
        ]
      },
      {
        Sid    = "AllowConsume"
        Effect = "Allow"
        Action = [
          "kafka-cluster:ReadData",
          "kafka-cluster:DescribeTopic"
        ]
        Resource = [
          var.source_msk_cluster_arn,
          var.target_msk_cluster_arn,
          "arn:aws:kafka:${local.region}:${local.account_id}:topic/${var.source_msk_cluster_name}/*",
          "arn:aws:kafka:${local.region}:${local.account_id}:topic/${var.target_msk_cluster_name}/*"
        ]
      },
      {
        Sid    = "AllowProduce"
        Effect = "Allow"
        Action = [
          "kafka-cluster:WriteData"
        ]
        Resource = [
          var.source_msk_cluster_arn,
          var.target_msk_cluster_arn,
          "arn:aws:kafka:${local.region}:${local.account_id}:topic/${var.source_msk_cluster_name}/*",
          "arn:aws:kafka:${local.region}:${local.account_id}:topic/${var.target_msk_cluster_name}/*"
        ]
      },
      {
        Sid    = "AllowCreateTopic"
        Effect = "Allow"
        Action = [
          "kafka-cluster:CreateTopic"
        ]
        Resource = [
          var.source_msk_cluster_arn,
          var.target_msk_cluster_arn,
          "arn:aws:kafka:${local.region}:${local.account_id}:topic/${var.source_msk_cluster_name}/*",
          "arn:aws:kafka:${local.region}:${local.account_id}:topic/${var.target_msk_cluster_name}/*"
        ]
      },
      {
        Sid    = "AllowAlterGroup"
        Effect = "Allow"
        Action = [
          "kafka-cluster:AlterGroup",
          "kafka-cluster:DescribeGroup"
        ]
        Resource = [
          var.source_msk_cluster_arn,
          var.target_msk_cluster_arn,
          "arn:aws:kafka:${local.region}:${local.account_id}:group/${var.source_msk_cluster_name}/*",
          "arn:aws:kafka:${local.region}:${local.account_id}:group/${var.target_msk_cluster_name}/*"
        ]
      },
      {
        Sid    = "AllowAlterOperationPermissions"
        Effect = "Allow"
        Action = [
          "kafka-cluster:AlterTopic",
          "kafka-cluster:AlterCluster"
        ]
        Resource = [
          var.source_msk_cluster_arn,
          var.target_msk_cluster_arn,
          "arn:aws:kafka:${local.region}:${local.account_id}:topic/${var.source_msk_cluster_name}/*",
          "arn:aws:kafka:${local.region}:${local.account_id}:topic/${var.target_msk_cluster_name}/*"
        ]
      },
      {
        Sid    = "AllowAlterConfigurationermissions"
        Effect = "Allow"
        Action = [
          "kafka-cluster:DescribeTopicDynamicConfiguration",
          "kafka-cluster:AlterTopicDynamicConfiguration"
        ]
        Resource = [
          var.source_msk_cluster_arn,
          var.target_msk_cluster_arn,
          "arn:aws:kafka:${local.region}:${local.account_id}:topic/${var.source_msk_cluster_name}/*",
          "arn:aws:kafka:${local.region}:${local.account_id}:topic/${var.target_msk_cluster_name}/*"
        ]
      }
    ]
  })

  depends_on = [
    aws_iam_role.this
  ]
}
