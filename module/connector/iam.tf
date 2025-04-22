locals {
  create_service_exec_role = local.create && var.service_exec_role_arn == null
  service_exec_role_arn    = local.create_service_exec_role ? aws_iam_role.this[0].arn : var.service_exec_role_arn
  name_prefix_iam          = "${local.project}${replace(title(var.connector_name), "-", "")}"
  service_exec_role_name   = "${local.name_prefix_iam}MskConnectorServiceExecRole"

  service_exec_trust_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "MSKConnectorAssumeRole",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : [
            "kafkaconnect.amazonaws.com"
          ]
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role" "this" {
  count                 = local.create_service_exec_role ? 1 : 0
  name                  = local.service_exec_role_name
  path                  = var.service_exec_role_path
  description           = var.service_exec_role_description
  assume_role_policy    = local.service_exec_trust_policy
  permissions_boundary  = var.service_exec_role_permissions_boundary
  force_detach_policies = true

  tags = merge(local.tags, var.service_exec_role_tags, {
    Name = local.connector_name
  })
}

resource "aws_iam_role_policy" "msk" {
  count = local.create_service_exec_role ? 1 : 0
  name  = "${local.name_prefix_iam}MskConnectorServiceExecPolicy"
  role  = aws_iam_role.this[0].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowMSKConnect"
        Effect = "Allow"
        Action = [
          "kafka-cluster:Connect",
          "kafka-cluster:DescribeCluster"
        ]
        Resource = [
          "arn:aws:kafka:${local.region}:${local.account_id}:cluster/${local.cluster_name}/*"
        ]
      },
      {
        Sid    = "AllowTopic"
        Effect = "Allow"
        Action = [
          "kafka-cluster:CreateTopic",
          "kafka-cluster:WriteData",
          "kafka-cluster:ReadData",
          "kafka-cluster:DescribeTopic"
        ]
        Resource = [
          "arn:aws:kafka:${local.region}:${local.account_id}:topic/${local.cluster_name}/*"
        ]
      },
      {
        Sid    = "AllowGroup"
        Effect = "Allow"
        Action = [
          "kafka-cluster:AlterGroup",
          "kafka-cluster:DescribeGroup"
        ]
        Resource = [
          "arn:aws:kafka:${local.region}:${local.account_id}:group/${local.cluster_name}/*"
        ]
      }
    ]
  })

  depends_on = [
    aws_iam_role.this[0]
  ]
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = {for k, v in var.service_exec_role_additional_policies : k => v if local.create_service_exec_role}

  policy_arn = each.value
  role       = aws_iam_role.this[0].name

  depends_on = [
    aws_iam_role.this[0]
  ]
}
