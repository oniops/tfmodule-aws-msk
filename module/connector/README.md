# tfmodule-aws-msk/connector

tfmodule-aws-msk/connector is Terraform module which creates AWS MSK Connect.

## How to clone

```sh
git clone https://github.com/oniops/tfmodule-aws-msk.git
cd tfmodule-aws-msk/module/connector
```

## Context
This module uses the tfmodule-context Terraform module to define MSK services and resources, providing a standardized naming policy and tagging conventions for AWS Best Practice model, and a consistent datasource reference module. For more information about Context, see the <a href="https://github.com/oniops/tfmodule-context">tfmodule-context</a> Terraform module.

## Usage

### Example

This is an example of creating a Connector that captures changes to a specific table in a MySQL Database using the MySQL Debezium plugin and then produces a topic message.

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
  connector_name = "my-msk-connector"
}

module "connector" {
  source               = "git::https://github.com/oniops/tfmodule-aws-msk.git//module/connector?ref=v1.0.0"
  msk_context          = module.ctx.context
  connector_name       = local.connector_name
  kafkaconnect_version = "2.7.1"                                      # It must be specified as a version compatible with the version of Kafka Cluster.
  cluster_name         = "my-msk-cluster-name"                        # The target Kafka Cluster name.
  subnet_ids           = ["subnet-001122334455", "subnet-66778899aa"] # This is the subnet where the MSK Connector will be deployed.
  security_groups      = ["sg-001122334455", "sg-66778899aa"]         # This is the security group that will be integrated into the MSK Connector. It must be able to access Kafka's broker node and target database.
  bootstrap_servers    = ["msk-broker-node-server-1:9096", "msk-broker-node-server-2:9096"] # The address of the Kafka broker node to connect to.
  authentication_type  = "NONE"      # This is the client authentication method used when connecting to a Kafka broker node. This example is a connection that does not use authentication.
  encryption_type      = "PLAINTEXT" # Whether to use TLS encryption when communicating with Kafka broker nodes. This example uses plaintext communication without encryption.
  s3_bucket_arn        = "arn:aws:s3:::my-plugin-s3-bucket-arn" # The ARN of the S3 bucket where the MySQL Debezium plugin was uploaded.
  s3_file_key          = "path/to/mysql-debezium-plugin.zip"    # Path to the S3 bucket where the MySQL Debezium plugin is uploaded.
  
  connector_configuration = {
      "connector.class"       = "io.debezium.connector.mysql.MySqlConnector"
      "tasks.max"             = "1"
      "database.hostname"     = "my-database-hostname" # This is the connection address for the MySQL Database.
      "database.port"         = "3306"                 # This is the connection port for the MySQL Database.
      "database.user"         = "HAVE TO CHANGE"       # MySQL Database 인증 시 사용 할 유저 이름 입니다.
      "database.password"     = "HAVE TO CHANGE"       # The user name to use when authenticating to the MySQL Database.
      "database.server.id"    = "123456"               # A unique number for the MySQL Database. This value must not conflict with other connectors. Set it to a random integer between 1 and 2^32-1.
      "database.include.list" = "my-database"          # The name of the database to capture data from.
  }
}
```

## Variables

Describes the Input/Output variables used in tfmodule-aws-msk/connector.

### [Input Variables](https://oniops.github.io/tfmodule-aws-msk/readme-connector-input-variables.html)

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
            <td>Determines whether MSK Connector resources will be created.</td>
            <td>bool</td>
            <td>true</td>
            <td>no</td>
            <td>false</td>
        </tr>
        <tr>
            <td>context</td>
            <td>Specify context values.This module uses the tfmodule-context Terraform module to define MSK connector services and resources, providing a standardized naming policy and tagging conventions, and a consistent datasource reference module.For more information about Context, see the <a href = "https://github.com/oniops/tfmodule-context">tfmodule-context</a>Terraform module.</td>
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
            <td>additional_tags</td>
            <td>Specify additional tags for resources created in this module. All default tags for all resources depend on Context values. Please refer "tags" value in <a href = "https://github.com/oniops/tfmodule-context">tfmodule-context</a> module.</td>
            <td>map(string)</td>
            <td>null</td>
            <td>no</td>
            <td>{Timestamp = "20101231", CompanyURL = "https://my-company-url.com"}</td>
        </tr>
        <tr>
            <td>create_connector_role</td>
            <td>Determines whether MSK Connect role will be created. If false, you must enter "service_exec_role_arn" for MSK Connector's IAM Role.</td>
            <td>bool</td>
            <td>true</td>
            <td>no</td>
            <td>false</td>
        </tr>
        <tr>
            <td>service_exec_role_arn</td>
            <td>The Amazon Resource Name (ARN) of the IAM role used by the connector to access the Amazon Web Services resources that it needs. The types of resources depends on the logic of the connector. For example, a connector that has Amazon S3 as a destination must have permissions that allow it to write to the S3 destination bucket.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"arn:aws:iam::111122223333:role/myConnectorRole"</td>
        </tr>
        <tr>
            <td>service_exec_role_description</td>
            <td>Description of the Connector Service Execution role.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"This is myConnectorRole"</td>
        </tr>
        <tr>
            <td>service_exec_role_permissions_boundary</td>
            <td>ARN of the policy that is used to set the permissions boundary for the Connector Service Execution IAM role.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td><pre>
            {
                Version = "2012-10-17",
                Statement = [
                  {
                    Effect   = "Allow",
                    Action   = [
                      "s3:*",
                      "ec2:*",
                      "cloudwatch:*"
                    ],
                    Resource = "*"
                  }
                ]
            }
            </pre></td>
        </tr>
        <tr>
            <td>service_exec_role_additional_policies</td>
            <td>Additional policies to be added to the Connector Service Execution IAM role.</td>
            <td>map(string)</td>
            <td>null</td>
            <td>no</td>
            <td>
            {
                "AAA_Policy" = "AAA_POLICY_ARN",
                "BBB_Policy" = "BBB_POLICY_ARN"
            }
            </td>
        </tr>
        <tr>
            <td>connector_description</td>
            <td>A description of the resource or configuration.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"This is my-msk-connector"</td>
        </tr>
        <tr>
            <td>connector_name</td>
            <td>Name of the MSK Connector. The name format depends on Context values. Please refer "name_prefix" value in <a href="https://github.com/oniops/tfmodule-context">tfmodule-context</a> module.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"my-msk-connector"</td>
        </tr>
        <tr>
            <td>connector_name</td>
            <td>Fullname of the MSK Connector. If you don't want to set auto-formatted MSK Cluster name due to Context values, you can specify this value.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"my-msk-connector-fullname"</td>
        </tr>
        <tr>
            <td>kafkaconnect_version</td>
            <td>Specify the desired Kafka software version. The version should be compatible with Kafka Cluster.</td>
            <td>string</td>
            <td></td>
            <td>yes</td>
            <td>"2.7.1"</td>
        </tr>
        <tr>
            <td>connector_configuration</td>
            <td>A map of keys to values that represent the configuration for the connector.</td>
            <td>map(string)</td>
            <td></td>
            <td>yes</td>
            <td>
                {
                  "connector.class" = "io.debezium.connector.jdbc.JdbcSinkConnector"
                  "tasks.max"       = "1"
                }
            </td>
        </tr>
        <tr>
            <td>cluster_name</td>
            <td>Kafka Cluster(MSK) Name to connect to.</td>
            <td>string</td>
            <td></td>
            <td>yes</td>
            <td>"my-msk-cluster"</td>
        </tr>
        <tr>
            <td>bootstrap_servers</td>
            <td>A comma-listed-string of broker endpoints of Kafka Cluster to connect to.</td>
            <td>string</td>
            <td></td>
            <td>yes</td>
            <td>"broker-endpoint-1:9092,broker-endpoint-2:9092"</td>
        </tr>
        <tr>
            <td>subnet_ids</td>
            <td>A list of subnets for MSK Connector to place.</td>
            <td>list(string)</td>
            <td></td>
            <td>yes</td>
            <td>["subnet-111122223333","subnet-aaaabbbbcccc"]</td>
        </tr>
        <tr>
            <td>security_groups</td>
            <td>A list of security groups of MSK Connector.</td>
            <td>list(string)</td>
            <td></td>
            <td>yes</td>
            <td>["sg-001122334455", "sg-66778899aa"]</td>
        </tr>
        <tr>
            <td>encryption_type</td>
            <td>Encryption settings for Kafka cluster in transit. Choose either TLS or PLAINTEXT.</td>
            <td>string</td>
            <td>"TLS"</td>
            <td>no</td>
            <td>"PLAINTEXT"</td>
        </tr>
        <tr>
            <td>authentication_type</td>
            <td>Client authentication settings for Kafka cluster. Choose either IAM or NONE.</td>
            <td>string</td>
            <td>"IAM"</td>
            <td>no</td>
            <td>"NONE"</td>
        </tr>
        <tr>
            <td>enable_autoscaling</td>
            <td>Indicates whether autoscaling is enabled. It is only for "Provisioned" type of MSK Connector.</td>
            <td>bool</td>
            <td>false</td>
            <td>no</td>
            <td>true</td>
        </tr>
        <tr>
            <td>autoscaling_mcu_count</td>
            <td>The number of MCUs to allocate for provisioned capacity. MCU : MSK Connect Unit, 1vCPU/4GiB Memory for 1 MCU.</td>
            <td>number</td>
            <td>1</td>
            <td>no</td>
            <td>3</td>
        </tr>
        <tr>
            <td>autoscaling_min_worker_count</td>
            <td>The minimum number of workers for autoscaling.</td>
            <td>number</td>
            <td>1</td>
            <td>no</td>
            <td>3</td>
        </tr>
        <tr>
            <td>autoscaling_max_worker_count</td>
            <td>The maximum number of workers for autoscaling.</td>
            <td>number</td>
            <td>2</td>
            <td>no</td>
            <td>5</td>
        </tr>
        <tr>
            <td>scale_in_cpu_utilization_percentage</td>
            <td>CPU utilization percentage threshold for scaling in.</td>
            <td>number</td>
            <td>20</td>
            <td>no</td>
            <td>30</td>
        </tr>
        <tr>
            <td>scale_out_cpu_utilization_percentage</td>
            <td>CPU utilization percentage threshold for scaling out.</td>
            <td>number</td>
            <td>80</td>
            <td>no</td>
            <td>70</td>
        </tr>
        <tr>
            <td>provisioned_capacity_mcu_count</td>
            <td>The number of MCUs to allocate for provisioned capacity.</td>
            <td>number</td>
            <td>1</td>
            <td>no</td>
            <td>3</td>
        </tr>
        <tr>
            <td>provisioned_capacity_worker_count</td>
            <td>The number of workers to allocate for provisioned capacity. Worker : Executes task for MSK Connector.</td>
            <td>number</td>
            <td>1</td>
            <td>no</td>
            <td>3</td>
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
            <td>firehose_logs_enabled</td>
            <td>Indicates whether you want to enable or disable streaming broker logs to Kinesis Data Firehose.</td>
            <td>bool</td>
            <td>false</td>
            <td>no</td>
            <td>true</td>
        </tr>
        <tr>
            <td>firehose_delivery_stream</td>
            <td>Name of the Kinesis Data Firehose delivery stream to deliver logs to.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"my-firehose-stream"</td>
        </tr>
        <tr>
            <td>s3_logs_enabled</td>
            <td>Indicates whether you want to enable or disable streaming broker logs to S3.</td>
            <td>bool</td>
            <td>false</td>
            <td>no</td>
            <td>true</td>
        </tr>
        <tr>
            <td>s3_logs_bucket</td>
            <td>Name of the S3 bucket to deliver logs to.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"my-s3-bucket"</td>
        </tr>
        <tr>
            <td>s3_logs_prefix</td>
            <td>Prefix to append to the folder name.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"path/to/s3/logs"</td>
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
            <td>"my-cloudwatch-log-group"</td>
        </tr>
        <tr>
            <td>cloudwatch_log_group_retention_in_days</td>
            <td>Specifies the number of days you want to retain log events in the log group.</td>
            <td>number</td>
            <td>14</td>
            <td>no</td>
            <td>21</td>
        </tr>
        <tr>
            <td>cloudwatch_log_group_kms_key_id</td>
            <td>The ARN of the KMS Key to use when encrypting log data.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"arn:aws:kms:ap-northeast-2:111122223333:key/000ab111-cd23-4455-a667-78899aabbccddef"</td>
        </tr>
        <tr>
            <td>cloudwatch_log_group_class</td>
            <td>Specifies the log class of the log group. Possible values are: STANDARD or INFREQUENT_ACCESS.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"STANDARD"</td>
        </tr>
        <tr>
            <td>create_worker_configuration</td>
            <td>Determines whether to create connect worker configuration.</td>
            <td>bool</td>
            <td>true</td>
            <td>no</td>
            <td>false</td>
        </tr>
        <tr>
            <td>worker_configuration_name</td>
            <td>The name of the worker configuration.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"my-worker-config-name"</td>
        </tr>
        <tr>
            <td>worker_configuration_fullname</td>
            <td>The full name of the worker configuration.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"my-worker-config-fullname"</td>
        </tr>
        <tr>
            <td>worker_configuration_description</td>
            <td>A summary description of the worker configuration.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"This is my-worker-config"</td>
        </tr>
        <tr>
            <td>properties_file_content</td>
            <td>These are the settings for configuring workers in MSK Connect. These settings determine how the workers operate, how they transform data, and how they communicate with the Kafka cluster.</td>
            <td>map(string)</td>
            <td>null</td>
            <td>no</td>
            <td><pre>
                {
                  "key.converter"                  = "org.apache.kafka.connect.json.JsonConverter"
                  "value.converter"                = "org.apache.kafka.connect.json.JsonConverter"
                  "key.converter.schemas.enable"   = false
                  "value.converter.schemas.enable" = true
                }
            </pre></td>
        </tr>
        <tr>
            <td>plugin_name</td>
            <td>The name of the custom plugin to be used with MSK Connect.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"my-connector-plugin-name"</td>
        </tr>
        <tr>
            <td>plugin_fullname</td>
            <td>The full name of the custom plugin to be used with MSK Connect.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"my-connector-plugin-fullname"</td>
        </tr>
        <tr>
            <td>plugin_description</td>
            <td>A textual description of the custom plugin being created.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"This is my-connector-plugin"</td>
        </tr>
        <tr>
            <td>content_type</td>
            <td>Specifies the content type of the plugin file (e.g., ZIP or JAR).</td>
            <td>string</td>
            <td>"ZIP"</td>
            <td>no</td>
            <td>"JAR"</td>
        </tr>
        <tr>
            <td>s3_bucket_arn</td>
            <td>The Amazon Resource Name (ARN) of the S3 bucket where the plugin content is stored.</td>
            <td>string</td>
            <td></td>
            <td>yes</td>
            <td>"arn:aws:s3:::my-plugin-s3-bucket-arn"</td>
        </tr>
        <tr>
            <td>s3_file_key</td>
            <td>The key (path) to the specific file within the S3 bucket that contains the plugin.</td>
            <td>string</td>
            <td></td>
            <td>yes</td>
            <td>"path/to/custom/plugin"</td>
        </tr>
        <tr>
            <td>plugin_arn</td>
            <td>The Amazon Resource Name (ARN) of the custom plugin.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"arn:aws:kafkaconnect:us-east-1:123456789012:custom-plugin/mysql-debezium/abcdefgh-1234-5678-9abc-defghijklmno"</td>
        </tr>
        <tr>
            <td>plugin_revision</td>
            <td>The specific revision or version identifier of the custom plugin to be used.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"3"</td>
        </tr>
        <tr>
            <td>worker_configuration_arn</td>
            <td>The Amazon Resource Name (ARN) of the custom plugin.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"arn:aws:kafkaconnect:us-east-1:123456789012:worker-configuration/my-worker-config/abcdefgh-1234-5678-9abc-defghijklmno"</td>
        </tr>
        <tr>
            <td>worker_configuration_revision</td>
            <td>The specific revision or version identifier of the custom plugin to be used.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"2"</td>
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
            <td>Amazon Resource Name (ARN) of the MSK Connector.</td>
            <td>string</td>
            <td>"arn:aws:kafkaconnect:us-east-1:123456789012:connector/my-connector/abcdefgh-1234-5678-9abc-defghijklmno"</td>
        </tr>
        <tr>
            <td>custom_plugin_arn</td>
            <td>Amazon Resource Name (ARN) of the Custom plugin.</td>
            <td>string</td>
            <td>"arn:aws:kafkaconnect:us-east-1:123456789012:custom-plugin/mysql-debezium/abcdefgh-1234-5678-9abc-defghijklmno"</td>
        </tr>
        <tr>
            <td>worker_configuration_arn</td>
            <td>Amazon Resource Name (ARN) of the Worker configuration.</td>
            <td>string</td>
            <td>"arn:aws:kafkaconnect:us-east-1:123456789012:worker-configuration/my-worker-config/abcdefgh-1234-5678-9abc-defghijklmno"</td>
        </tr>
    </tbody>
</table>

# LICENSE

- This module is customized from [terraform-aws-msk-kafka-cluster](https://github.com/terraform-aws-modules/terraform-aws-msk-kafka-cluster), and follows the license policy of [terraform-aws-msk-kafka-cluster](https://github.com/terraform-aws-modules/terraform-aws-msk-kafka-cluster).
- See for Apache-2.0 [LICENSE](https://github.com/oniops/tfmodule-aws-msk/blob/main/LICENSE).