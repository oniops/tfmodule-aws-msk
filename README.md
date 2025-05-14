# tfmodule-aws-msk

tfmodule-aws-msk is Terraform module which creates AWS MSK(Managed Streaming for Apache Kafka) resources.

## How to clone

```sh
git clone https://github.com/oniops/tfmodule-aws-msk.git
cd tfmodule-aws-msk
```

## Context
This module uses the tfmodule-context Terraform module to define MSK services and resources, providing a standardized naming policy and tagging conventions for AWS Best Practice model, and a consistent datasource reference module.
<br>
For more information about Context, see the [tfmodule-context](https://github.com/oniops/tfmodule-context) Terraform module.

## Usage

### Example 1 : Provisioned MSK Cluster - Standard Type Broker
For more details about Provisioned MSK Cluster - Standard Type Broker, Please see [this AWS Documentation](https://docs.aws.amazon.com/ko_kr/msk/latest/developerguide/msk-broker-types-standard.html).
<br>
This chapter explains how to provision standard type of broker node with provisioned type of MSK Cluster. The client authentication for broker node is SASL/IAM.

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
  cluster_name = "my-msk-cluster"
}

resource "aws_security_group" "this" {
  name        = "${local.cluster_name}"
  description = "MSK Cluster"
  vpc_id      = "my-vpc-id" # Enter VPC ID to place MSK Cluster.
}

resource "aws_security_group_rule" "client" {
  type              = "ingress"
  description       = "Client to MSK Cluster broker node"
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id
  cidr_blocks       = ["10.0.0.0/16"] # Recommend VPC CIDR as cidr_blocks. Enter Client IP if the IP can be specified.
  from_port         = 9098
  to_port           = 9098
}

module "msk" {
  source                 = "git::https://github.com/oniops/tfmodule-aws-msk.git?ref=v1.0.0"
  context                = module.ctx.context
  cluster_name           = local.cluster_name
  enable_client_auth_iam = true
  kafka_version          = "3.6.0"
  instance_type          = "kafka.t3.small"
  number_of_broker_nodes = 2
  client_subnets         = ["client-subnet-id-1", "client-subnet-id-2"] # Enter subnet ID to place MSK Cluster.
  ebs_volume_size        = 1000
  security_groups        = [aws_security_group.this.id]
}

# The endpoints of broker node will be displayed after MSK Cluster is created
output "endpoints" {
  value = module.msk.bootstrap_brokers
}
```
#### SASL/IAM Authentication

The authentication SASL/IAM to connect to broker node is controlled by IAM Policy. For example, necessary policies are below : 

 - Sid AllowMSKAccess  : Policies for connecting to the MSK Cluster.
 - Sid AllowMSKConsume : Policies for consuming the messages from the topics.
 - Sid AllowMSKProduce : Policies for producing the messages to the topics.
 - Sid AllowMSKTopicAccess : Policies for read configurations for topic and create/delete the topics.
 - Sid AllowMSKGroupAccess : Policies for read/create the consumer groups.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowMSKAccess",
      "Effect": "Allow",
      "Action": [
        "kafka-cluster:DescribeTransactionalId",
        "kafka-cluster:DescribeClusterDynamicConfiguration",
        "kafka-cluster:DescribeCluster",
        "kafka-cluster:Connect"
      ],
      "Resource": "arn:aws:kafka:ap-northeast-2:111122223333:cluster/my-demo-msk-cluster/*"
    },
    {
      "Sid": "AllowMSKConsume",
      "Effect": "Allow",
      "Action": [
        "kafka-cluster:ReadData",
        "kafka-cluster:DescribeTopic"
      ],
      "Resource": "arn:aws:kafka:ap-northeast-2:111122223333:topic/my-demo-msk-cluster/*"
    },
    {
      "Sid": "AllowMSKProduce",
      "Effect": "Allow",
      "Action": [
        "kafka-cluster:WriteData",
        "kafka-cluster:DescribeTopic"
      ],
      "Resource": "arn:aws:kafka:ap-northeast-2:111122223333:topic/my-demo-msk-cluster/*"
    },
    {
      "Sid": "AllowMSKTopicAccess",
      "Effect": "Allow",
      "Action": [
        "kafka-cluster:CreateTopic",
        "kafka-cluster:AlterTopic",        
        "kafka-cluster:DeleteTopic",
        "kafka-cluster:DescribeTopicDynamicConfiguration"        
      ],
      "Resource": "arn:aws:kafka:ap-northeast-2:111122223333:topic/my-demo-msk-cluster/*"
    },
    {
      "Sid": "AllowMSKGroupAccess",
      "Effect": "Allow",
      "Action": [
        "kafka-cluster:DescribeGroup",
        "kafka-cluster:AlterGroup"
      ],
      "Resource": "arn:aws:kafka:ap-northeast-2:111122223333:group/my-demo-msk-cluster/*"
    } 
  ]
}
```


<br>

### Example 2 : Provisioned MSK Cluster - Express Type Broker
For more details about Provisioned MSK Cluster - Express Type Broker, Please see [this AWS Documentation](https://docs.aws.amazon.com/ko_kr/msk/latest/developerguide/msk-broker-types-express.html).
<br>
This chapter explains how to provision express type of broker node with provisioned type of MSK Cluster. The client authentication for broker node is SASL/IAM.

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
  cluster_name = "my-msk-cluster"
}

resource "aws_security_group" "this" {
  name        = "${local.cluster_name}"
  description = "MSK Cluster"
  vpc_id      = "my-vpc-id" # Enter VPC ID to place MSK Cluster.
}

resource "aws_security_group_rule" "client" {
  type              = "ingress"
  description       = "Client to MSK Cluster broker node"
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id
  cidr_blocks       = ["10.0.0.0/16"] # Recommend VPC CIDR as cidr_blocks. Enter Client IP if the IP can be specified.
  from_port         = 9098
  to_port           = 9098
}

module "msk" {
  source                 = "git::https://github.com/oniops/tfmodule-aws-msk.git?ref=v1.0.0"
  context                = module.ctx.context
  cluster_name           = local.cluster_name
  enable_client_auth_iam = true
  kafka_version          = "3.6.0"
  
  # Enter express.* type of instance to user Express type of broker node.
  instance_type          = "express.m7g.large"

  # Enter subnet ID to place MSK Cluster. At least, it requires 3 available zones for Express type.  
  client_subnets         = ["client-subnet-id-1", "client-subnet-id-2", "client-subnet-id-3"] 
  number_of_broker_nodes = 3

  ebs_volume_size        = 1000
  security_groups        = [aws_security_group.this.id]
}

# The endpoints of broker node will be displayed after MSK Cluster is created
output "endpoints" {
  value = module.msk.bootstrap_brokers
}
```

Supported instance types for Express type of broker node are below :

- express.m7g.large
- express.m7g.xlarge
- express.m7g.2xlarge
- express.m7g.4xlarge
- express.m7g.8xlarge
- express.m7g.12xlarge
- express.m7g.16xlarge

<br>

### Example 3 : Serverless MSK Cluster
For more details about Serverless MSK Cluster, Please see [this AWS Documentation](https://docs.aws.amazon.com/ko_kr/msk/latest/developerguide/serverless.html).
<br>
This chapter explains how to provision serverless type of MSK Cluster. The client authentication for broker node is SASL/IAM.

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
  cluster_name = "my-msk-cluster"
}

resource "aws_security_group" "this" {
  name        = local.cluster_name
  description = "MSK Cluster"
  vpc_id      = "my-vpc-id" # Enter VPC ID to place MSK Cluster.
}

resource "aws_security_group_rule" "client" {
  type              = "ingress"
  description       = "Client to MSK Cluster broker node"
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id
  cidr_blocks       = ["10.0.0.0/16"] # Recommend VPC CIDR as cidr_blocks. Enter Client IP if the IP can be specified.
  from_port         = 9098
  to_port           = 9098
}

module "msk" {
  source                 = "git::https://github.com/oniops/tfmodule-aws-msk.git?ref=v1.0.0"
  context                = module.ctx.context
  cluster_name           = local.cluster_name
  kafka_version          = "3.6.0" 

  # Create Serverless type of MSK Cluster.
  # No need to set instance type, number of nodes, storage volume size for Serverless type of MSK Cluster.
  enable_serverless_cluster = true 
  
  client_subnets         = ["client-subnet-id-1", "client-subnet-id-2"]
  security_groups        = [aws_security_group.this.id]
  enable_client_auth_iam = true
}

# The endpoints of broker node will be displayed after MSK Cluster is created.
output "endpoints" {
  value = module.msk.bootstrap_brokers
}
```

## Variables

This chapter describes Input/Output variables using in tfmodule-aws-msk.

### [Input Variables](https://oniops.github.io/tfmodule-aws-msk/readme-cluster-input-variables.html)

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
        <td>Create or not MSK Cluster resource.</td>
        <td>bool</td>
        <td>true</td>
        <td>no</td>
        <td>false</td>
    </tr>
    <tr>
        <td>context</td>
        <td>Specify context values. This module uses the tfmodule-context Terraform module to define MSK services and resources, providing a standardized naming policy and tagging conventions, and a consistent datasource reference module. For more information about Context, see the <a href="https://github.com/oniops/tfmodule-context">tfmodule-context</a>Terraform module.</td>
        <td>map(string)</td>
        <td></td>
        <td>yes</td>
        <td><pre>
{
    project     = "demo"
    region      = "ap-northeast-2"
    environment = "Development"
    department  = "DevOps"
    owner       = "my_devops_team@example.com"
    customer    = "Example Customer"
    domain      = "example.com"
    pri_domain  = "example.internal"
}
        </pre></td>
    </tr>
    <tr>
        <td>cluster_name</td>
        <td>Name of the MSK cluster. The name format depends on Context values. Please refer "name_prefix" value in <a href="https://github.com/oniops/tfmodule-context">tfmodule-context</a> module.</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
        <td>"my-cluster"</td>
    </tr>
    <tr>
        <td>cluster_fullname</td>
        <td>Fullname of the MSK cluster. If you don't want to set auto-formatted MSK Cluster name due to Context values, you can specify this value.</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
        <td>"my-cluster-full-name"</td>
    </tr>    
    <tr>
        <td>additional_tags</td>
        <td>Specify additional tags for resources created in this module. All default tags for all resources depend on Context values. Please refer "tags" value in <a href="https://github.com/oniops/tfmodule-context">tfmodule-context</a> module.</td>
        <td>map(string)</td>
        <td>null</td>
        <td>no</td>
        <td>{Timestamp = "20101231", CompanyURL = "https://my-company-url.com"}</td>
    </tr>
    <tr>
        <td>enable_serverless_cluster</td>
        <td>Specify deployment type of MSK Cluster. If true, the type will be set as "Serverless". If false, the type will be set as "Provisioned"</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>false</td>
    </tr>
    <tr>
        <td>kafka_version</td>
        <td>(Cluster type - Provisioned only) Specify the desired Kafka software version. See <a href="https://docs.aws.amazon.com/ko_kr/msk/latest/developerguide/supported-kafka-versions.html">For supported Apache Kafka version.</a></td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
        <td>"3.6.0"</td>
    </tr>    
    <tr>
        <td>client_subnets</td>
        <td>A list of subnets to connect to in client VPC. <a href="https://docs.aws.amazon.com/msk/1.0/apireference/clusters.html#clusters-prop-brokernodegroupinfo-clientsubnets">document</a></td>
        <td>list(string)</td>
        <td></td>
        <td>yes</td>
        <td>["subnet-1111aaaa2222bbbb3", "subnet-4444cccc5555dddd6"]</td>
    </tr>
    <tr>
        <td>public_access_type</td>
        <td>Allow or not access from public to broker. "DISABLED" means that public access is turned off. "SERVICE_PROVIDED_EIPS" means that public access is turned on</td>
        <td>string</td>
        <td>"DISABLED"</td>
        <td>no</td>
        <td>"DISABLED" or "SERVICE_PROVIDED_EIPS"</td>
    </tr>
    <tr>
        <td>instance_type</td>
        <td>(Cluster type - Provisioned only) Specify the instance type to use for the kafka brokers. You can select not only instance type, also broker type (Standard or Express). See: <a href="https://aws.amazon.com/msk/pricing/">MSK Broker Instance Types</a></td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
        <td>"kafka.t3.small"</td>
    </tr>
    <tr>
        <td>number_of_broker_nodes</td>
        <td>(Cluster type - Provisioned only) The desired total number of broker nodes in the kafka cluster. The number must be the same or multiple of available zone.</td>
        <td>number</td>
        <td>null</td>
        <td>no</td>
        <td>1</td>
    </tr>    
    <tr>
        <td>security_groups</td>
        <td>A list of the security groups to associate with the elastic network interfaces to control who can communicate with the cluster</td>
        <td>list(string)</td>
        <td>null</td>
        <td>no</td>
        <td>["sg-111122223333", "sg-444455556666"]</td>
    </tr>
    <tr>
        <td>ebs_volume_size</td>
        <td>(Cluster type - Provisioned/Standard Broker node only) EBS Storage volumes size attached to MSK broker nodes only for standard type. The storage only can be scaled-out (not scaled-in). Available size : (min: 1, max: 16384, unit: GiB)</td>
        <td>number</td>
        <td>1000</td>
        <td>no</td>
        <td>512</td>
    </tr>
    <tr>
        <td>enable_provisioned_throughput</td>
        <td>(Cluster type - Provisioned/Standard Broker node only) Provisioned throughput is enabled or not. You can set storage I/O performance to enable this option.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>provisioned_volume_throughput</td>
        <td>(Cluster type - Provisioned/Standard Broker node only) Throughput value of the storage I/O performance for the data drive on each kafka broker node in MiB per second.</td>
        <td>number</td>
        <td>250</td>
        <td>no</td>
        <td>500</td>
    </tr>
    <tr>
        <td>enable_storage_autoscaling</td>
        <td>(Cluster type - Provisioned/Standard Broker node only) Determines whether autoscaling is enabled for storage. The autoscaling is only for scale-out of storage. The storage can be expended only once in 6 hours.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>scaling_max_size</td>
        <td>(Cluster type - Provisioned/Standard Broker node only) Max storage size for Kafka broker autoscaling.</td>
        <td>number</td>
        <td>250</td>
        <td>no</td>
        <td>300</td>
    </tr>
    <tr>
        <td>scaling_target_value</td>
        <td>(Cluster type - Provisioned/Standard Broker node only) The Kafka broker storage utilization at which scaling is initiated.</td>
        <td>number</td>
        <td>70</td>
        <td>no</td>
        <td>50</td>
    </tr>    
    <tr>
        <td>create_configuration</td>
        <td>(Cluster type - Provisioned only) Determines whether to create a MSK Cluster configuration.</td>
        <td>bool</td>
        <td>true</td>
        <td>no</td>
        <td>false</td>
    </tr>
    <tr>
        <td>configuration_arn</td>
        <td>(Cluster type - Provisioned only) ARN of an externally created configuration to use.</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
        <td>"arn:aws:kafka:ap-northeast-2:111122223333:configuration/dev-an2d-platform-mskcfg/11112222-3333-4444-5555-666677778888-1"</td>
    </tr>
    <tr>
        <td>configuration_name</td>
        <td>(Cluster type - Provisioned only) Specify cluster configuration name.</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
        <td>"my-msk-config"</td>
    </tr>
    <tr>
        <td>configuration_revision</td>
        <td>(Cluster type - Provisioned only) Revision of the externally created configuration to use.</td>
        <td>number</td>
        <td>null</td>
        <td>no</td>
        <td>2</td>
    </tr>
    <tr>
        <td>configuration_description</td>
        <td>(Cluster type - Provisioned only) Description of the configuration.</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
        <td>"This Configuration is for my-msk-cluster"</td>
    </tr>
    <tr>
        <td>configuration_kafka_versions</td>
        <td>(Cluster type - Provisioned only) Support Kafka version.</td>
        <td>list(string)</td>
        <td>null</td>
        <td>no</td>
        <td>["3.6.0"]</td>
    </tr>
    <tr>
        <td>configuration_server_properties</td>
        <td>(Cluster type - Provisioned only) Contents of the server.properties file. Supported properties are documented in the <a href="https://docs.aws.amazon.com/msk/latest/developerguide/msk-configuration-properties.html">MSK Developer Guide</a></td>
        <td>map(string)</td>
        <td>{}</td>
        <td>no</td>
        <td><pre>
{
    "auto.create.topics.enable"  = true
    "delete.topic.enable"        = true
    "log.cleanup.policy"         = "delete"
    "log.message.timestamp.type" = "LogAppendTime"
    "log.retention.hours"        = 72
}
        </pre></td>
    </tr>    
    <tr>
        <td>enable_client_noauth</td>
        <td>Allow or not client access(consume or produce...) to MSK broker nodes without authentication.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>enable_client_auth_iam</td>
        <td>SASL/IAM authentication is enabled or not client to access(consume or produce...) to MSK broker nodes. If enabled, the access is controlled by AWS IAM attached to client(Services or Applications)</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>enable_client_auth_scram</td>
        <td>SASL/SCRAM authentication is enabled or not client to access(consume or produce...) to MSK broker nodes. If enabled, the access is controlled by login(id/pw). It can be integrated with AWS Secrets Manager</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>client_auth_cert_authority_arns</td>
        <td>List of AWS Private CA Amazon Resource Name (ARN)s. If listed, broker checks client's certificates (Mutual TLS)</td>
        <td>list(string)</td>
        <td>null</td>
        <td>no</td>
        <td>["arn:aws:acm:ap-northeast-2:111122223333:certificate/a1b2c3d4-a1b2-c3d4-e5f6-112233445566"]</td>
    </tr>
    <tr>
        <td>encryption_at_rest_kms_key_arn</td>
        <td>Specify a KMS key short ID or ARN (it will always output an ARN) to use for encrypting stored data in MSK broker node storages. If no key is specified, an AWS managed KMS ('aws/msk' managed service) key will be used for encrypting the data at rest</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
        <td>"arn:aws:kms:ap-northeast-2:111122223333:key/012ab345-ab12-3344-a556-112233445566"</td>
    </tr>
    <tr>
        <td>encryption_in_transit_client_broker</td>
        <td>Encryption setting for data in transit between clients and brokers. Valid values: TLS, TLS_PLAINTEXT, and PLAINTEXT. If set "TLS", The broker only accepts TLS encrypted transit. If set "TLS_PLAINTEXT", The broker acce]pts both TLS encrypted and plain transit. If set "PLAINTEXT", The broker only accepts plain transit.</td>
        <td>string</td>
        <td>"TLS"</td>
        <td>no</td>
        <td>"TLS_PLAINTEXT"</td>
    </tr>
    <tr>
        <td>encryption_in_transit_in_cluster</td>
        <td>Whether data communication among broker nodes is encrypted.</td>
        <td>bool</td>
        <td>true</td>
        <td>no</td>
        <td>false</td>
    </tr>
    <tr>
        <td>create_scram_secret_association</td>
        <td>Determines whether to create SASL/SCRAM secret association.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>scram_secret_list</td>
        <td>List of AWS Secrets Manager secret ARNs to associate with SCRAM.</td>
        <td>list(string)</td>
        <td>[]</td>
        <td>no</td>
        <td>["arn:aws:secretsmanager:ap-northeast-2:111122223333:secret:mysecret-1", "arn:aws:secretsmanager:ap-northeast-2:111122223333:secret:mysecret-2"]</td>
    </tr>
    <tr>
        <td>storage_mode</td>
        <td>Controls storage mode for supported storage tiers. For Standard type of broker, tiered storage transfer old data to low-cost storage. Available values : "LOCAL" or "TIERED". See <a href="https://docs.aws.amazon.com/ko_kr/msk/latest/developerguide/msk-tiered-storage.html">MSK Tiered storage for Standard broker</a> for more details.</td>
        <td>string</td>
        <td>"LOCAL"</td>
        <td>no</td>
        <td>"TIERED"</td>
    </tr>
    <tr>
        <td>enable_vpc_connectivity</td>
        <td>Whether to use multiple VPC Connection. To access the MSK Cluster from client assosiated with another VPC, VPC Connectivity must be enabled. See <a href="https://docs.aws.amazon.com/msk/latest/developerguide/aws-access-mult-vpc.html">document</a> for more details.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>vpc_connectivity_auth_tls</td>
        <td>Enables TLS authentication for VPC connectivity. IF enabled, broker checks client's certificates (Mutual TLS) accessing from another VPC.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>vpc_connectivity_auth_iam</td>
        <td>SASL/IAM authentication is enabled or not client to access(consume or produce...) from anther VPC to MSK broker nodes. If enabled, the access is controlled by AWS IAM attached to client(Services or Applications)</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>vpc_connectivity_auth_scram</td>
        <td>SASL/SCRAM authentication is enabled or not client to access(consume or produce...) from anther VPC to MSK broker nodes. If enabled, the access is controlled by login(id/pw). It can be integrated with AWS Secrets Manager.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>    
    <tr>
        <td>enhanced_monitoring</td>
        <td>Specify the desired enhanced MSK CloudWatch monitoring level. It can set details of MSK cluster and brokers metrics. Available options are "DEFAULT" | "PER_BROKER" | "PER_TOPIC_PER_BROKER" | "PER_TOPIC_PER_PARTITION". See <a href="https://docs.aws.amazon.com/msk/latest/developerguide/monitoring.html">Monitoring Amazon MSK with Amazon CloudWatch.</a></td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
        <td>"PER_BROKER"</td>
    </tr>
    <tr>
        <td>cloudwatch_logs_enabled</td>
        <td>Indicates whether you want to enable or disable streaming broker logs to Cloudwatch Logs.</td>
        <td>bool</td>
        <td>true</td>
        <td>no</td>
        <td>false</td>
    </tr>    
    <tr>
        <td>cloudwatch_log_group_class</td>
        <td>Specifies the log class of the log group. Possible values are: "STANDARD" or "INFREQUENT_ACCESS".</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
        <td>"STANDARD"</td>
    </tr>
    <tr>
        <td>firehose_logs_enabled</td>
        <td>Indicates whether you want to enable or disable streaming MSK Broker node logs to Kinesis Data Firehose.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>firehose_delivery_stream</td>
        <td>Name of the Kinesis Data Firehose delivery stream to deliver MSK Broker node logs to.</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
        <td>"my-kinesis-stream"</td>
    </tr>
    <tr>
        <td>s3_logs_enabled</td>
        <td>Indicates whether you want to enable or disable streaming MSK Broker node logs to S3.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>s3_logs_bucket</td>
        <td>Name of the S3 bucket to deliver MSK Broker node logs to.</td>
        <td>string</td>
        <td>false</td>
        <td>no</td>
        <td>"my-s3-bucket"</td>
    </tr>
    <tr>
        <td>s3_logs_prefix</td>
        <td>Prefix to append to the bucket object name for MSK Broker node logs.</td>
        <td>string</td>
        <td>false</td>
        <td>no</td>
        <td>"msk-cluster/my-cluster/logs"</td>
    </tr>
    <tr>
        <td>jmx_exporter_enabled</td>
        <td>Indicates whether you want to enable or disable the JMX Exporter for Prometheus.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>node_exporter_enabled</td>
        <td>Indicates whether you want to enable or disable the Node Exporter for Prometheus.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>create_cloudwatch_log_group</td>
        <td>Determines whether to create a CloudWatch log group.</td>
        <td>bool</td>
        <td>true</td>
        <td>no</td>
        <td>false</td>
    </tr>
    <tr>
        <td>cloudwatch_log_group_name</td>
        <td>Name of the Cloudwatch Log Group to deliver logs to.</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
        <td>"my-cw-loggroup-name"</td>
    </tr>
    <tr>
        <td>cloudwatch_log_group_retention_in_days</td>
        <td>Specifies the number of days you want to retain log events in the log group.</td>
        <td>number</td>
        <td>14</td>
        <td>no</td>
        <td>7</td>
    </tr>
    <tr>
        <td>cloudwatch_log_group_kms_key_id</td>
        <td>The ARN of the KMS Key to use when encrypting log data.</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
        <td>"11112222-aabb-3344-ccdd-55667788abcd"</td>
    </tr>
</tbody>
</table>

### [Output Variables](https://oniops.github.io/tfmodule-aws-msk/readme-cluster-output-variables.html)

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
        <td>Amazon Resource Name (ARN) of the MSK cluster.</td>
        <td>string</td>
        <td>"arn:aws:kafka:us-east-1:111122223333:cluster/demomsk/11112222-3344-5566-7788-152f5289c6dd-14"</td>
    </tr>
    <tr>
        <td>cluster_name</td>
        <td>Name of the MSK cluster</td>
        <td>string</td>
        <td>"my-msk-cluster"</td>
    </tr>
    <tr>
        <td>cluster_uuid</td>
        <td>UUID of the MSK cluster, for use in IAM policies</td>
        <td>string</td>
        <td>"11112222-3344-5566-7788-152f5289c6dd-14"</td>
    </tr>    
    <tr>
        <td>bootstrap_brokers_plaintext</td>
        <td>Comma separated list of one or more hostname:port pairs of kafka brokers suitable to bootstrap connectivity to the kafka cluster. Contains a value if encryption_in_transit_client_broker is set to PLAINTEXT or TLS_PLAINTEXT.</td>
        <td>list(string)</td>
        <td>["b-1.demomsk.112233.c14.kafka.us-east-1.amazonaws.com:9092","b-2.demomsk.445566.c14.kafka.us-east-1.amazonaws.com:9092"]</td>
    </tr>
    <tr>
        <td>bootstrap_brokers_sasl_iam</td>
        <td>One or more DNS names (or IP addresses) and SASL IAM port pairs. This attribute will have a value if encryption_in_transit_client_broker is set to TLS_PLAINTEXT or TLS and client_authentication_sasl_iam is set to true.</td>
        <td>list(string)</td>
        <td>["b-1.demomsk.112233.c14.kafka.us-east-1.amazonaws.com:9098","b-2.demomsk.445566.c14.kafka.us-east-1.amazonaws.com:9098"]</td>
    </tr>
    <tr>
        <td>bootstrap_brokers_sasl_scram</td>
        <td>One or more DNS names (or IP addresses) and SASL SCRAM port pairs. This attribute will have a value if encryption_in_transit_client_broker is set to TLS_PLAINTEXT or TLS and `client_authentication_sasl_scram` is set to true.</td>
        <td>list(string)</td>
        <td>["b-1.demomsk.112233.c14.kafka.us-east-1.amazonaws.com:9096","b-2.demomsk.445566.c14.kafka.us-east-1.amazonaws.com:9096"]</td>
    </tr>
    <tr>
        <td>bootstrap_brokers_tls</td>
        <td>One or more DNS names (or IP addresses) and TLS port pairs. This attribute will have a value if encryption_in_transit_client_broker is set to TLS_PLAINTEXT or TLS.</td>
        <td>list(string)</td>
        <td>["b-1.demomsk.112233.c14.kafka.us-east-1.amazonaws.com:9094","b-2.demomsk.445566.c14.kafka.us-east-1.amazonaws.com:9094"]</td>
    </tr>
    <tr>
        <td>bootstrap_brokers</td>
        <td>Comma separated list of one or more hostname:port pairs of kafka brokers suitable to bootstrap connectivity to the kafka cluster.</td>
        <td>list(string)</td>
        <td>["b-1.demomsk.112233.c14.kafka.us-east-1.amazonaws.com:9092","b-2.demomsk.445566.c14.kafka.us-east-1.amazonaws.com:9098"]</td>
    </tr>
    <tr>
        <td>bootstrap_brokers_authentication</td>
        <td>Name string of brokers authentication for client. SASL_IAM for IAM, SASL_SCRAM for SASL/SCRAM, TLS for mutual TLS.</td>
        <td>string</td>
        <td>"SASL_IAM"</td>
    </tr>
    <tr>
        <td>zookeeper_connect_string</td>
        <td>A comma separated list of one or more hostname:port pairs to use to connect to the Apache Zookeeper cluster. The returned values are sorted alphabetically.</td>
        <td>list(string)</td>
        <td>["z-3.demomsk.aabbcc.c14.kafka.us-east-1.amazonaws.com:2181","z-1.demomsk.11aabb.c14.kafka.us-east-1.amazonaws.com":2181,"z-2.demomsk.abcd1234.c14.kafka.us-east-1.amazonaws.com:2181"]</td>
    </tr>
    <tr>
        <td>zookeeper_connect_string_tls</td>
        <td>A comma separated list of one or more hostname:port pairs to use to connect to the Apache Zookeeper cluster via TLS. The returned values are sorted alphabetically.</td>
        <td>list(string)</td>
        <td>["z-3.demomsk.aabbcc.c14.kafka.us-east-1.amazonaws.com:2182","z-1.demomsk.11aabb.c14.kafka.us-east-1.amazonaws.com":2182,"z-2.demomsk.abcd1234.c14.kafka.us-east-1.amazonaws.com:2182"]</td>
    </tr>
    <tr>
        <td>configuration_arn</td>
        <td>Amazon Resource Name (ARN) of the MSK Cluster configuration.</td>
        <td>string</td>
        <td>"arn:aws:kafka:us-east-1:111122223333:configuration/demomskcfg/1234abcd-1111-2222-33aa-aaaabbbbcccc-14"</td>
    </tr>
    <tr>
        <td>configuration_latest_revision</td>
        <td>Latest revision of the MSK Cluster configuration.</td>
        <td>string</td>
        <td>"7"</td>
    </tr>
    <tr>
        <td>scram_secret_association_id</td>
        <td>The ID of the MSK SCRAM secret association.</td>
        <td>string</td>
        <td>"arn:aws:kafka:us-east-1:111122223333:cluster/demomsk/abcd1234-abcd-5678-abcd-1234abcd5678-1/scram-secret-association/efgh5678-ijkl-9012-mnop-3456qrst7890"</td>
    </tr>
    <tr>
        <td>log_group_arn</td>
        <td>The Amazon Resource Name (ARN) specifying the Cloudwatch log group.</td>
        <td>string</td>
        <td>"arn:aws:logs:us-east-1:111122223333:log-group:/msk/demomsk"</td>
    </tr>
    <tr>
        <td>appautoscaling_policy_arn</td>
        <td>The ARN assigned by AWS to the scaling policy.</td>
        <td>string</td>
        <td>"arn:aws:autoscaling:us-east-1:111122223333:scalingPolicy:11112222-3333-aabb-4444-555566667777:resource/msk/default/demomsk:pplocyName/my-as-policy-name"</td>
    </tr>
    <tr>
        <td>appautoscaling_policy_name</td>
        <td>The scaling policy's name.</td>
        <td>string</td>
        <td>"my-as-policy-name"</td>
    </tr>
</tbody>
</table>

# Appendix

## How to connect to MSK

To test connect too MSK Cluster, you need to prepare kafka-script.

<br>

First, install Java in your machine.

```sh
sudo yum -y install java-11
```

After then, download management script for Kafka provided by Apache Kafka. Enter Kafka version of MSK Cluster on {YOUR MSK VERSION}.

```sh
wget https://archive.apache.org/dist/kafka/{YOUR MSK VERSION}/kafka_2.13-{YOUR MSK VERSION}.tgz
```

For example, the Apache Kafka version is 3.6.0, execute following command :

```sh
wget https://archive.apache.org/dist/kafka/3.6.0/kafka_2.13-3.6.0.tgz
```

Decompress downloaded TAR file.

```sh
tar -xzf kafka_2.13-{YOUR MSK VERSION}.tgz
```

Mode to kafka_2.13-{YOUR MSK VERSION}/config directory and create client.properties file included authentication information to connect.

```sh
cd kafka_2.13-{YOUR MSK VERSION}/config
touch client.properties
```

Write contents of client.properties
The contents of the client.properties file are written according to the client authentication method as follows. If the client authentication method is NOAUTH (enable_client_noauth == true), set security.protocol=PLAINTEXT.

```sh
security.protocol=SASL_SSL
```

If you'd like to specify "consumer group", you can set by the property like :
```sh
group.id={CONSUMER GROUP ID}
```

If your client authentication method is SASL/IAM (enable_client_auth_iam == true), first navigate to the kafka_2.13-{YOUR MSK VERSION}/libs directory and run the following command to download the Amazon MSK IAM JAR file.

```sh
cd kafka_2.13-{YOUR MSK VERSION}/libs
wget https://github.com/aws/aws-msk-iam-auth/releases/download/v2.3.0/aws-msk-iam-auth-2.3.0-all.jar
```

Next, fill in the client.properties file. If the client and broker communicate unencrypted, set security.protocol=PLAINTEXT.

```sh
security.protocol=SASL_SSL
sasl.mechanism=AWS_MSK_IAM
sasl.jaas.config=software.amazon.msk.auth.iam.IAMLoginModule required;
sasl.client.callback.handler.class=software.amazon.msk.auth.iam.IAMClientCallbackHandler
```

If the client authentication method is SASL/SCRAM (enable_client_auth_scram == true), set it as follows. If the client and broker communicate unencrypted, set security.protocol=PLAINTEXT.

```sh
security.protocol=SASL_SSL
sasl.mechanism=SCRAM-SHA-512
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required username="{USERNAME}" password="{PASSWORD}";
```

Finally, check if you can successfully connect to the cluster and retrieve the topic list using the command below.

```sh
kafka_2.13-{YOUR MSK VERSION}/bin/kafka-topics.sh --list \
    --bootstrap-server "{YOUR KAFKA ENDPOINT}" \
    --command-config kafka_2.13-{YOUR MSK VERSION}/config/client.properties
```

An example result is shown below.

```sh
MSKTutorialTopic
TestTopic
__amazon_msk_canary
__consumer_offsets
```

## How to test topic

Explain how to create a topic, produce it, and test the consume method. First, create a topic with the command below.

```sh
kafka_2.13-{YOUR MSK VERSION}/bin/kafka-topics.sh --create \
    --bootstrap-server "{YOUR KAFKA ENDPOINT}" \
    --command-config kafka_2.13-{YOUR MSK VERSION}/config/client.properties
    --replication-factor 2 \
    --partitions 1 \
    --topic "example-topic"
```

When a topic is created, it is printed as follows.

```sh
Created example-topic
```

Next, produce a message to the topic created with the command below.

```sh
kafka_2.13-{YOUR MSK VERSION}/bin/kafka-console-producer.sh \
    --bootstrap-server "{YOUR KAFKA ENDPOINT}" \
    --producer.config kafka_2.13-{YOUR MSK VERSION}/config/client.properties \
    --topic "example-topic"
```

After running the script, enter the message to be produced in the CLI as shown below. When message produce is complete, enter ctrl+c to exit the script.

```sh
>example-msg-1
>example-msg-2
>^C
```

Consume the produced messages in the created topic using the command below.

```sh
kafka_2.13-{YOUR MSK VERSION}/bin/kafka-console-consumer.sh \
    --bootstrap-server "{YOUR KAFKA ENDPOINT}" \
    --consumer.config kafka_2.13-{YOUR MSK VERSION}/config/client.properties \
    --from-beginning \
    --topic "example-topic"
```

After executing the script, the message produced in the CLI is output as shown below. When message consumption is finished, enter ctrl+c to exit the script.

```sh
example-msg-1
example-msg-2
^C
```

## How to check importance values

This section describes some importance values in Kafka broker node.

### Offset

Don't forget setting `group.id` property in the `client.properties` to specify consumer group.
Go to [How to connect to MSK](#How-to-connect-to-MSK) section for the details.

```
group.id={CONSUMER GROUP ID}
```

Then, run below command to check offset :

```sh
kafka_2.13-{YOUR MSK VERSION}/bin/kafka-consumer-groups.sh \
    --bootstrap-server "{YOUR KAFKA ENDPOINT}" \
    --command-config kafka_2.13-{YOUR MSK VERSION}/config/client.properties \
    --describe \
    --group "{CONSUMER GROUP ID}"
```

After executing the script, data shows like :

```sh
GROUP                 TOPIC           PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG             CONSUMER-ID     HOST            CLIENT-ID
{CONSUMER GROUP ID}   example-topic   0          2               2               0               -               -               -
```

If you'd like to change offset, run below command :

```sh
kafka_2.13-{YOUR MSK VERSION}/bin/kafka-consumer-groups.sh \
    --bootstrap-server "{YOUR KAFKA ENDPOINT}" \
    --command-config kafka_2.13-{YOUR MSK VERSION}/config/client.properties \
    --reset-offsets \
    --topic "example-topic" \
    --group "{CONSUMER GROUP ID}"
    --to-offset {OFFSET TO CHANGE} \
    --execute
```

Then, check applied offset using below command :

```sh
kafka_2.13-{YOUR MSK VERSION}/bin/kafka-consumer-groups.sh \
    --bootstrap-server "{YOUR KAFKA ENDPOINT}" \
    --command-config kafka_2.13-{YOUR MSK VERSION}/config/client.properties \
    --describe \
    --group "{CONSUMER GROUP ID}"
```

After executing the script, data shows like :

```sh
GROUP                 TOPIC           PARTITION  CURRENT-OFFSET      LOG-END-OFFSET  LAG             CONSUMER-ID     HOST            CLIENT-ID
{CONSUMER GROUP ID}   example-topic   0          {OFFSET TO CHANGE}  2               0               -               -               -
```


### Partition

To check partition of topics, run below command :

```sh
kafka_2.13-{YOUR MSK VERSION}/bin/kafka-topics.sh \
    --bootstrap-server "{YOUR KAFKA ENDPOINT}" \
    --describe
```

After executing the script, data shows like :

```sh
Topic: __amazon_msk_canary	TopicId: aaBbCcDd12345678ffffcCCC	PartitionCount: 2	ReplicationFactor: 2	Configs: min.insync.replicas=1,cleanup.policy=delete,retention.ms=86400000,message.format.version=3.0-IV1,unclean.leader.election.enable=true,retention.bytes=-1
Topic: __amazon_msk_canary	Partition: 0	Leader: 2	Replicas: 2,1	Isr: 2,1
Topic: __amazon_msk_canary	Partition: 1	Leader: 1	Replicas: 1,2	Isr: 1,2
Topic: example-topic	TopicId: aaBbCcDd12345678ffffcQQQ	PartitionCount: 1	ReplicationFactor: 2	Configs: min.insync.replicas=1,message.format.version=3.0-IV1,unclean.leader.election.enable=true
Topic: example-topic	Partition: 0	Leader: 2	Replicas: 2,1	Isr: 2,1
Topic: __consumer_offsets	TopicId: 12345Dd12345678ffffcCCC	PartitionCount: 50	ReplicationFactor: 2	Configs: compression.type=producer,min.insync.replicas=1,cleanup.policy=compact,segment.bytes=104857600,message.format.version=3.0-IV1,unclean.leader.election.enable=true
Topic: __consumer_offsets	Partition: 0	Leader: 1	Replicas: 1,2	Isr: 1,2
...
```

# LICENSE
 - See for Apache-2.0 [LICENSE](https://github.com/oniops/tfmodule-aws-msk/blob/main/LICENSE).
 - This module is customized from [terraform-aws-msk-kafka-cluster](https://github.com/terraform-aws-modules/terraform-aws-msk-kafka-cluster), and follows the license policy of [terraform-aws-msk-kafka-cluster](https://github.com/terraform-aws-modules/terraform-aws-msk-kafka-cluster).