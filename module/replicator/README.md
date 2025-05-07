# tfmodule-aws-msk/replicator

tfmodule-aws-msk/replicator is Terraform module which creates AWS MSK Replicator resources.

## How to clone

```sh
git clone https://github.com/oniops/tfmodule-aws-msk.git
cd tfmodule-aws-msk/module/replicator
```

## Context
This module uses the tfmodule-context Terraform module to define MSK services and resources, providing a standardized naming policy and tagging conventions for AWS Best Practice model, and a consistent datasource reference module. For more information about Context, see the <a href="https://github.com/oniops/tfmodule-context">tfmodule-context</a> Terraform module.

## Usage

### Example

Describes how to provision a Replicator that copies topic data from a source MSK Cluster to a target MSK Cluster.

```hcl
module "ctx" {
  source = "git::https://github.com/oniops/tfmodule-context.git?ref=v1.3.2"
  context = {
    project     = "demo"
    region      = "ap-northeast-2"
    environment = "Development"
    department  = "DevOps"
    owner       = "my_devops_team@example.com"
    customer    = "Example Customer"
    domain      = "example.com"
    pri_domain  = "example.internal"
  }
}

locals {
  replicator_name = "my-msk-replicator"
}

resource "aws_security_group" "this" {
  name        = var.replicator_name
  description = "MSK Replicator"
  vpc_id      = "my-vpc-id" # Enter the VPC ID where the Replicator will be deployed.
}

resource "aws_security_group_rule" "source" {
  type              = "egress"
  description       = "Replicator to source MSK Cluster broker node"
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id

  # If the broker node IP of the source MSK Cluster can be specified, replace it with that IP.
  # It is recommended to specify the Security Group of the Source MSK Cluster using the source_security_group_id attribute, if possible.
  cidr_blocks = ["0.0.0.0/0"]

  # Enter the broker node port of the Source MSK Cluster.
  from_port = 9098
  to_port   = 9098
}

resource "aws_security_group_rule" "target" {
  type              = "egress"
  description       = "Replicator to target MSK Cluster broker node"
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id

  # If the broker node IP of the target MSK Cluster can be specified, replace it with that IP.
  # It is recommended to specify the Security Group of the Target MSK Cluster using the source_security_group_id attribute, if possible.
  cidr_blocks = ["0.0.0.0/0"]

  # Enter the broker node port of the target MSK Cluster.
  from_port = 9098
  to_port   = 9098
}

module "replicator" {
  source          = "git::https://github.com/oniops/tfmodule-msk.git/module/replicator?ref=v1.0.0"
  context         = var.context
  replicator_name = local.replicator_name

  source_msk_cluster_arn  = "arn:aws:kafka:ap-northeast-2:123456789012:cluster/my-source-msk-cluster/abc12d3e-1234-5678-9012-95de01ee639c-s1"
  source_msk_cluster_name = "my-source-msk-cluster"
  source_msk_cluster_subnet_ids = ["source-msk-subnet-id-1", "source-msk-subnet-id-2"]
  # Enter the subnet ID where the MSK Cluster is deployed.
  # You need to add an ingress rule to the Security Group used in the Source MSK Cluster to allow the Replicator to access the Broker Nodes in the Source MSK Cluster.
  source_msk_cluster_security_groups_ids = [aws_security_group.this.id]

  target_msk_cluster_arn  = "arn:aws:kafka:ap-northeast-2:123456789012:cluster/my-target-msk-cluster/12d3eabc-4321-9876-5432-ee639c95de01-1s"
  target_msk_cluster_name = "my-target-msk-cluster"
  target_msk_cluster_subnet_ids = ["target-msk-subnet-id-1", "target-msk-subnet-id-2"]
  # Enter the subnet ID where the MSK Cluster is deployed.
  # You need to add an ingress rule to the Security Group being used on the Target MSK Cluster to allow the Replicator to access the Broker Nodes on the Target MSK Cluster.
  target_msk_cluster_security_groups_ids = [aws_security_group.this.id]

  # All topics are eligible for replication.
  topics_to_replicate = ["*"]
}
```

## Variables

Describes the Input/Output variables used in tfmodule-aws-msk/replicator.

### Input Variables

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Description</th>
            <th>Type</th>
            <th>Default</th>
            <th>Required</th>
            <th>Example</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>create</td>
            <td>Determines whether replicator resources will be created.</td>
            <td>bool</td>
            <td>true</td>
            <td>no</td>
            <td>false</td>
        </tr>
        <tr>
            <td>context</td>
            <td>Specify context values.This module uses the tfmodule-context Terraform module to define MSK services and resources, providing a standardized naming policy and tagging conventions, and a consistent datasource reference module.For more information about Context, see the <a href = "https://github.com/oniops/tfmodule-context">tfmodule-context</a>Terraform module.</td>
            <td>map(string)</td>
            <td></td>
            <td>yes</td>
            <td><pre>
            {
                project = "demo"
                region = "ap-northeast-2"
                environment = "Development"
                department  = "DevOps"
                owner = "my_devops_team@example.com"
                customer = "Example Customer"
                domain = "example.com"
                pri_domain = "example.internal"
            }
            </pre></td>
        </tr>
        <tr>
            <td>replicator_name</td>
            <td>Name of the MSK Replicator. The name format depends on Context values. Please refer "name_prefix" value in <a href = "https://github.com/oniops/tfmodule-context">tfmodule-context</a> module.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"my-replicator"</td>
        </tr>
        <tr>
            <td>replicator_fullname</td>
            <td>Fullname of the MSK Replicator. If you don't want to set auto-formatted MSK Replicator name due to Context values, you can specify this value.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"my-replicator-full-name"</td>
        </tr>
        <tr>
            <td>additional_tags</td>
            <td>Specify additional tags for resources created in this module. All default tags for all resources depend on Context values. Please refer "tags" value in <a href = "https://github.com/oniops/tfmodule-context">tfmodule-context</a> module.</td>
            <td>map(string)</td>
            <td>null</td>
            <td>no</td>
            <td>{Timestamp = "20101231", CompanyURL = "https://my-company-url.com"}</td>
        </tr>
        <tr>
            <td>description</td>
            <td>Description of the MSK Replicator.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"This replicator is for my-msk-cluster"</td>
        </tr>
        <tr>
            <td>source_msk_cluster_name</td>
            <td>The name of source MSK Cluster. Topics in this MSK Cluster will be copied to target MSK Cluster.</td>
            <td>string</td>
            <td></td>
            <td>yes</td>
            <td>"my-source-msk-cluster"</td>
        </tr>
        <tr>
            <td>source_msk_cluster_arn</td>
            <td>The AWS ARN of source MSK Cluster. Topics in this MSK Cluster will be copied to target MSK Cluster.</td>
            <td>string</td>
            <td></td>
            <td>yes</td>
            <td>"arn:aws:kafka:ap-northeast-2:123456789012:cluster/my-source-msk-cluster/abc12d3e-1234-5678-9012-95de01ee639c-s1"</td>
        </tr>
        <tr>
            <td>source_msk_cluster_subnet_ids</td>
            <td>The list of source MSK cluster subnets to connect to in the virtual private cloud (VPC). AWS creates elastic network interfaces inside these subnets to allow communication between your MSK Cluster and the replicator.</td>
            <td>list(string)</td>
            <td></td>
            <td>yes</td>
            <td>["source-msk-subnet-id-1", "source-msk-subnet-id-2"]</td>
        </tr>
        <tr>
            <td>source_msk_cluster_security_groups_ids</td>
            <td>The source MSK cluster security groups to associate with the ENIs used by the replicator. If a security group is not specified, the default security group associated with the VPC is used.</td>
            <td>list(string)</td>
            <td></td>
            <td>yes</td>
            <td>["security-group-id-for-source-msk-cluster"]</td>
        </tr>
        <tr>
            <td>target_msk_cluster_name</td>
            <td>The name of target MSK Cluster. Topics in source MSK Cluster will be copied to this MSK Cluster.</td>
            <td>string</td>
            <td></td>
            <td>yes</td>
            <td>"my-target-msk-cluster"</td>
        </tr>
        <tr>
            <td>target_msk_cluster_arn</td>
            <td>The AWS ARN of target MSK Cluster. Topics in source MSK Cluster will be copied to this MSK Cluster.</td>
            <td>string</td>
            <td></td>
            <td>yes</td>
            <td>"arn:aws:kafka:ap-northeast-2:123456789012:cluster/my-target-msk-cluster/12d3eabc-4321-9876-5432-ee639c95de01-1s"</td>
        </tr>
        <tr>
            <td>target_msk_cluster_subnet_ids</td>
            <td>The list of target MSK cluster subnets to connect to in the virtual private cloud (VPC). AWS creates elastic network interfaces inside these subnets to allow communication between your MSK Cluster and the replicator.</td>
            <td>list(string)</td>
            <td></td>
            <td>yes</td>
            <td>["target-msk-subnet-id-1", "target-msk-subnet-id-2"]</td>
        </tr>
        <tr>
            <td>target_msk_cluster_security_groups_ids</td>
            <td>The target MSK cluster security groups to associate with the ENIs used by the replicator. If a security group is not specified, the default security group associated with the VPC is used.</td>
            <td>list(string)</td>
            <td></td>
            <td>yes</td>
            <td>["security-group-id-for-target-msk-cluster"]</td>
        </tr>
        <tr>
            <td>target_compression_type</td>
            <td>The type of compression to use writing records to target MSK cluster. Available options are NONE | GZIP | SNAPPY | LZ4 | ZSTD".</td>
            <td>string</td>
            <td>"NONE"</td>
            <td>no</td>
            <td>"GZIP"</td>
        </tr>
        <tr>
            <td>topic_name_configuration</td>
            <td>Configuration for specifying replicated topic names should be the same as their corresponding upstream topics or prefixed with source cluster alias. Available options are PREFIXED_WITH_SOURCE_CLUSTER_ALIAS | IDENTICAL. If set PREFIXED_WITH_SOURCE_CLUSTER_ALIAS, copied topic name starts with source MSK Cluster name. If set IDENTICAL, copied topic name is the same as origin topic name.</td>
            <td>string</td>
            <td>"PREFIXED_WITH_SOURCE_CLUSTER_ALIAS"</td>
            <td>no</td>
            <td>"IDENTICAL"</td>
        </tr>
        <tr>
            <td>topics_to_replicate</td>
            <td>List of regular expression patterns indicating the topics to copy.</td>
            <td>list(string)</td>
            <td>[".*"]</td>
            <td>no</td>
            <td>["my-topic-1", "prefixed-topic-*", "*-suffixed-topic]</td>
        </tr>
        <tr>
            <td>topics_to_exclude</td>
            <td>List of regular expression patterns indicating the topics that should not be replica.</td>
            <td>list(string)</td>
            <td>null</td>
            <td>no</td>
            <td>["my-excluded-topic-1", "prefixed-excluded-topic-*", "*-suffixed-excluded-topic]</td>
        </tr>
        <tr>
            <td>detect_and_copy_new_topics</td>
            <td>Whether to periodically check for new topics and partitions.</td>
            <td>bool</td>
            <td>true</td>
            <td>no</td>
            <td>false</td>
        </tr>
        <tr>
            <td>copy_access_control_lists_for_topics</td>
            <td>Whether to periodically configure remote topic ACLs to match their corresponding upstream topics.</td>
            <td>bool</td>
            <td>true</td>
            <td>no</td>
            <td>false</td>
        </tr>
        <tr>
            <td>copy_topic_configurations</td>
            <td>Whether to periodically configure remote topics to match their corresponding upstream topics.</td>
            <td>bool</td>
            <td>true</td>
            <td>no</td>
            <td>false</td>
        </tr>
        <tr>
            <td>starting_position</td>
            <td>Configuration for specifying the position(offset) in the topics to start replicating from. Available options are LATEST | EARLIEST. If set LATEST, it copies from latest message in the topic. If set EARLIEST, it copies from beginning of topic.</td>
            <td>string</td>
            <td>"LATEST"</td>
            <td>no</td>
            <td>"EARLIEST"</td>
        </tr>
        <tr>
            <td>consumer_groups_to_replicate</td>
            <td>List of regular expression patterns indicating the consumer groups to copy.</td>
            <td>list(string)</td>
            <td>[".*"]</td>
            <td>no</td>
            <td>["my-consumer-group", "consumer-group-system.*"]</td>
        </tr>
        <tr>
            <td>consumer_groups_to_exclude</td>
            <td>List of regular expression patterns indicating the consumer groups that should not be replicated.</td>
            <td>list(string)</td>
            <td>null</td>
            <td>no</td>
            <td>["my-consumer-group", "consumer-group-system.*"]</td>
        </tr>
        <tr>
            <td>detect_and_copy_new_consumer_groups</td>
            <td>Whether to periodically check for new consumer groups to copy.</td>
            <td>bool</td>
            <td>true</td>
            <td>no</td>
            <td>false</td>
        </tr>
        <tr>
            <td>synchronise_consumer_group_offsets</td>
            <td>Whether to periodically write the translated offsets to __consumer_offsets topic in target cluster.</td>
            <td>bool</td>
            <td>true</td>
            <td>no</td>
            <td>false</td>
        </tr>
    </tbody>
</table>

### Output Variables

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Description</th>
            <th>Type</th>
            <th>Example</th>
        </tr>
    </thead>
        <tbody>
        <tr>
            <td>arn</td>
            <td>Amazon Resource Name (ARN) of the MSK Replicator.</td>
            <td>string</td>
            <td>"arn:aws:kafka:us-east-1:111122223333:configuration/my-msk-replicator/11112222-3344-5566-7788-152f5289c6dd-14"</td>
        </tr>
    </tbody>
</table>

# LICENSE

- This module is customized from [terraform-aws-msk-kafka-cluster](https://github.com/terraform-aws-modules/terraform-aws-msk-kafka-cluster), and follows the license policy of [terraform-aws-msk-kafka-cluster](https://github.com/terraform-aws-modules/terraform-aws-msk-kafka-cluster). 
- See for Apache-2.0 [LICENSE](https://github.com/oniops/tfmodule-aws-msk/blob/main/LICENSE).