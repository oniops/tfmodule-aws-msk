# tfmodule-aws-msk

tfmodule-aws-msk is terraform module which creates AWS MSK(Managed Streaming for Apache Kafka) resources.
<br>
This module is customized from [terraform-aws-msk-kafka-cluster](https://github.com/terraform-aws-modules/terraform-aws-msk-kafka-cluster), and follows the license policy of [terraform-aws-msk-kafka-cluster](https://github.com/terraform-aws-modules/terraform-aws-msk-kafka-cluster).

## How to clone

```sh
git clone https://github.com/oniops/tfmodule-aws-msk.git
cd tfmodule-aws-msk
```

## Variables

tf-module-aws-msk에서 사용되는 Input/Output 변수에 대해서 설명 합니다.

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
        <td>See: <a href="https://github.com/oniops/tfmodule-context">tfmodule-context</a></td>
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
        <td>(Cluster type - Provisioned only) Specify the instance type to use for the kafka brokers. You can select not only instance type, also broker type (Standard or Express).</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
        <td>See: <a href="https://aws.amazon.com/msk/pricing/">MSK Broker Instance Types</a></td>
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
        <td>(Cluster type - Provisioned/Standard Broker node only) EBS Storage volumes size attached to MSK broker nodes only for standard type. The storage only can be scaled-out (not scaled-in).</td>
        <td>number</td>
        <td>1000</td>
        <td>no</td>
        <td>512 (min: 1, max: 16384, unit: GiB)</td>
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
        <td>"arn:aws:kafka:ap-northeast-2:370166107047:configuration/dev-an2d-platform-mskcfg/11112222-3333-4444-5555-666677778888-1"</td>
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
        <td>(Cluster type - Provisioned only) Contents of the server.properties file.</td>
        <td>map(string)</td>
        <td>{}</td>
        <td>no</td>
        <td>Supported properties are documented in the <a href="https://docs.aws.amazon.com/msk/latest/developerguide/msk-configuration-properties.html">MSK Developer Guide</a></td>
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
        <td>"arn:aws:logs:us-east-1:410362304746:log-group:/msk/demomsk"</td>
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

## Usage

예제를 통해 리소스 프로비저닝 및 테스트 방법을 설명 합니다.

### Prepare

TODO :: 스크립트가 먼저 준비 된 후 클러스터 프로비저닝 코드를 보여줄지.. 반대로 할지.. 결정 필요
MSK Cluster를 프로비저닝 한 후 테스트를 하기 위해 kafka-script를 준비해야 합니다.

먼저 테스트를 위한 클라이언트 머신에 Java를 설치 합니다.

```sh
sudo yum -y install java-11
```

그 다음, Apache Kafka에서 제공하는 Cluster 관리용 스크립트를 다운로드 합니다. {YOUR MSK VERSION} 에는 프로비저닝 한 MSK Cluster의 Kafka 버전을 기입 합니다.

```sh
wget https://archive.apache.org/dist/kafka/{YOUR MSK VERSION}/kafka_2.13-{YOUR MSK VERSION}.tgz
```

예를 들어 Amazon MSK를 Apache Kafka 버전이 3.6.0인 경우 다음 명령을 실행합니다.

```sh
wget https://archive.apache.org/dist/kafka/3.6.0/kafka_2.13-3.6.0.tgz
```

다운로드 한 TAR 압축 파일을 압축해제 합니다. 명령어는 다운로드 한 디렉토리에서 수행 합니다.

```sh
tar -xzf kafka_2.13-{YOUR MSK VERSION}.tgz
```

kafka_2.13-{YOUR MSK VERSION}/config 디렉토리로 이동하여 연결에 사용 할 인증정보가 담긴 client.properties 를 생성 합니다.

```sh
cd kafka_2.13-{YOUR MSK VERSION}/config
touch client.properties
```

client.properties 파일의 내용은 아래와 같이 클라이언트 인증 방식에 따라서 작성 합니다.

#### 클라이언트 인증 방식이 NOAUTH 인 경우 (enable_client_noauth == true)

- 클라이언트와 브로커가 암호화 되지 않은 통신을 하는 경우 security.protocol=PLAINTEXT로 설정 해주세요.

```sh
security.protocol=SASL_SSL
```

#### 클라이언트 인증 방식이 SASL/IAM 인 경우 (enable_client_auth_iam == true)

- 먼저 kafka_2.13-{YOUR MSK VERSION}/libs 디렉터리로 이동하고 다음 명령을 실행하여 Amazon MSK IAM JAR 파일을 다운로드합니다.

```sh
cd kafka_2.13-{YOUR MSK VERSION}/libs
wget https://github.com/aws/aws-msk-iam-auth/releases/download/v2.3.0/aws-msk-iam-auth-2.3.0-all.jar
```

- 그 다음 client.properties 파일에 내용을 기입 합니다.
- 클라이언트와 브로커가 암호화 되지 않은 통신을 하는 경우 security.protocol=PLAINTEXT로 설정 해주세요.

```sh
security.protocol=SASL_SSL
sasl.mechanism=AWS_MSK_IAM
sasl.jaas.config=software.amazon.msk.auth.iam.IAMLoginModule required;
sasl.client.callback.handler.class=software.amazon.msk.auth.iam.IAMClientCallbackHandler
```

#### 클라이언트 인증 방식이 SASL/SCRAM 인 경우 (enable_client_auth_scram == true)

- 클라이언트와 브로커가 암호화 되지 않은 통신을 하는 경우 security.protocol=PLAINTEXT로 설정 해주세요.

```sh
security.protocol=SASL_SSL
sasl.mechanism=SCRAM-SHA-512
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required username="{USERNAME}" password="{PASSWORD}";
```

마지막으로 아래와 같은 명령어를 통해 정상적으로 클러스터에 접근하여 토픽 리스트를 가져올 수 있는지 확인 합니다.

```sh
kafka_2.13-{YOUR MSK VERSION}/bin/kafka-topics.sh --list \
    --bootstrap-server "{YOUR KAFKA ENDPOINT}" \
    --command-config kafka_2.13-{YOUR MSK VERSION}/config/client.properties
```

결과 예시는 아래와 같습니다.

```sh
MSKTutorialTopic
TestTopic
__amazon_msk_canary
__consumer_offsets
```

<br>

### Example 1 : Provisioned MSK Cluster - Standard Type Broker

Provisioned 타입의 MSK Cluster에서 Standard 타입의 브로커 노드를 프로비저닝 및 테스트 하는 방법을 설명 합니다.

#### How to provision

Standard 타입의 브로커 노드는 아래와 같이 구성 합니다. 브로커에서 사용하는 클라이언트 인증 방식은 SASL/IAM 입니다.

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
  vpc_id      = "my-vpc-id" # MSK Cluster가 배치될 VPC ID를 입력 합니다.
}

resource "aws_security_group_rule" "client" {
  type              = "ingress"
  description       = "Client to MSK Cluster broker node"
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id
  cidr_blocks       = ["0.0.0.0/0"] # 클라이언트 IP 특정이 가능 한 경우 해당 IP로 대치 합니다.
  from_port         = 9098
  to_port           = 9098
}

module "msk" {
  source                 = "git::https://github.com/oniops/tfmodule-msk.git?ref=v1.0.0"
  context                = module.ctx.context
  cluster_name           = local.cluster_name
  enable_client_auth_iam = true
  kafka_version          = "3.6.0"
  instance_type          = "kafka.t3.small"
  number_of_broker_nodes = 2
  client_subnets         = ["client-subnet-id-1", "client-subnet-id-2"] # MSK Cluster가 배치될 서브넷 ID를 입력 합니다.
  ebs_volume_size        = 1000
  security_groups        = [aws_security_group.this.id]
  tags                   = module.ctx.tags
}

# MSK 클러스터 생성이 완료되면 클러스터의 브로커 Endpoint가 출력 됩니다.
output "endpoints" {
  value = module.msk.bootstrap_brokers
}
```

<br>

#### How to Test

TODO :: 프로비저닝 후 테스트하는 방법은 모두 같은데 이걸 각 Hands-On 별로 두는게 맞을까?

- 프로비저닝이 완료되면 아래와 같이 토픽의 생성과 Produce, 그리고 Consume을 테스트할 수 있습니다.
- MSK 클러스터 생성이 완료되면 출력되는 클러스터의 브로커 Endpoint를 사용하여 연결 합니다.

먼저 아래의 명령어로 토픽을 생성 합니다.

```sh
kafka_2.13-{YOUR MSK VERSION}/bin/kafka-topics.sh --create \
    --bootstrap-server "{YOUR KAFKA ENDPOINT}" \
    --command-config kafka_2.13-{YOUR MSK VERSION}/config/client.properties
    --replication-factor 2 \
    --partitions 1 \
    --topic "example-topic"
```

토픽이 생성되면 아래와 같이 출력 됩니다.

```sh
Created example-topic
```

다음으로, 아래의 명령어로 생성된 토픽에 메세지를 Produce 합니다.

```sh
kafka_2.13-{YOUR MSK VERSION}/bin/kafka-console-producer.sh \
    --bootstrap-server "{YOUR KAFKA ENDPOINT}" \
    --producer.config kafka_2.13-{YOUR MSK VERSION}/config/client.properties \
    --topic "example-topic"
```

스크립트 실행 후 아래와 같이 CLI에 Produce 할 메세지를 입력 합니다. 메세지 Produce가 끝나면 ctrl+c 를 입력하여 스크립트를 종료 합니다.

```sh
>example-msg-1
>example-msg-2
>^C
```

아래의 명령어를 이용하여 생성된 토픽에 Produce한 메세지를 Consume 합니다.

```sh
kafka_2.13-{YOUR MSK VERSION}/bin/kafka-console-consumer.sh \
    --bootstrap-server "{YOUR KAFKA ENDPOINT}" \
    --consumer.config kafka_2.13-{YOUR MSK VERSION}/config/client.properties \
    --offset latest \
    --topic "example-topic"
```

스크립트 실행 후 아래와 같이 CLI에 Produce 하였던 메세지가 출력 됩니다. 메세지 Consume이 끝나면 ctrl+c 를 입력하여 스크립트를 종료 합니다.

```sh
example-msg-1
example-msg-2
^C
```

### Example 2 : Provisioned MSK Cluster - Express Type Broker

Provisioned 타입의 MSK Cluster에서 Standard 타입의 브로커 노드를 프로비저닝 및 테스트 하는 방법을 설명 합니다. 지원하는 Express 타입의 브로커 노드에 대한 인스턴스 타입은 아래와 같습니다.

- express.m7g.large
- express.m7g.xlarge
- express.m7g.2xlarge
- express.m7g.4xlarge
- express.m7g.8xlarge
- express.m7g.12xlarge
- express.m7g.16xlarge

#### How to provision

Express 타입의 브로커 노드는 아래와 같이 구성 합니다. 브로커에서 사용하는 클라이언트 인증 방식은 SASL/IAM 입니다. 

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
  vpc_id      = "my-vpc-id" # MSK Cluster가 배치될 VPC ID를 입력 합니다.
}

resource "aws_security_group_rule" "client" {
  type              = "ingress"
  description       = "Client to MSK Cluster broker node"
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id
  cidr_blocks       = ["0.0.0.0/0"] # 클라이언트 IP 특정이 가능 한 경우 해당 IP로 대치 합니다.
  from_port         = 9098
  to_port           = 9098
}

module "msk" {
  source                 = "git::https://github.com/oniops/tfmodule-msk.git?ref=v1.0.0"
  context                = module.ctx.context
  cluster_name           = local.cluster_name
  enable_client_auth_iam = true
  kafka_version          = "3.6.0"
  
  # Express 타입의 브로커를 사용하기 위해 express.* 타입의 인스턴스를 사용 합니다.
  instance_type          = "express.m7g.large"

  # MSK Cluster가 배치될 서브넷 ID를 입력 합니다. Express 타입의 브로커 노드는 최소 3개의 가용영역에 배치되어야 합니다.  
  client_subnets         = ["client-subnet-id-1", "client-subnet-id-2" "client-subnet-id-3"] 
  number_of_broker_nodes = 3

  ebs_volume_size        = 1000
  security_groups        = [aws_security_group.this.id]
  tags                   = module.ctx.tags
}

# MSK 클러스터 생성이 완료되면 클러스터의 브로커 Endpoint가 출력 됩니다.
output "endpoints" {
  value = module.msk.bootstrap_brokers
}
```


<br>

#### How to Test

TODO :: 프로비저닝 후 테스트하는 방법은 모두 같은데 이걸 각 Hands-On 별로 두는게 맞을까?

- 프로비저닝이 완료되면 아래와 같이 토픽의 생성과 Produce, 그리고 Consume을 테스트할 수 있습니다.
- MSK 클러스터 생성이 완료되면 출력되는 클러스터의 브로커 Endpoint를 사용하여 연결 합니다.

먼저 아래의 명령어로 토픽을 생성 합니다.

```sh
kafka_2.13-{YOUR MSK VERSION}/bin/kafka-topics.sh --create \
    --bootstrap-server "{YOUR KAFKA ENDPOINT}" \
    --command-config kafka_2.13-{YOUR MSK VERSION}/config/client.properties
    --replication-factor 2 \
    --partitions 1 \
    --topic "example-topic"
```

토픽이 생성되면 아래와 같이 출력 됩니다.

```sh
Created example-topic
```

다음으로, 아래의 명령어로 생성된 토픽에 메세지를 Produce 합니다.

```sh
kafka_2.13-{YOUR MSK VERSION}/bin/kafka-console-producer.sh \
    --bootstrap-server "{YOUR KAFKA ENDPOINT}" \
    --producer.config kafka_2.13-{YOUR MSK VERSION}/config/client.properties \
    --topic "example-topic"
```

스크립트 실행 후 아래와 같이 CLI에 Produce 할 메세지를 입력 합니다. 메세지 Produce가 끝나면 ctrl+c 를 입력하여 스크립트를 종료 합니다.

```sh
>example-msg-1
>example-msg-2
>^C
```

아래의 명령어를 이용하여 생성된 토픽에 Produce한 메세지를 Consume 합니다.

```sh
kafka_2.13-{YOUR MSK VERSION}/bin/kafka-console-consumer.sh \
    --bootstrap-server "{YOUR KAFKA ENDPOINT}" \
    --consumer.config kafka_2.13-{YOUR MSK VERSION}/config/client.properties \
    --offset latest \
    --topic "example-topic"
```

스크립트 실행 후 아래와 같이 CLI에 Produce 하였던 메세지가 출력 됩니다. 메세지 Consume이 끝나면 ctrl+c 를 입력하여 스크립트를 종료 합니다.

```sh
example-msg-1
example-msg-2
^C
```

### Example 3 : Serverless MSK Cluster

Serverless 타입의 MSK Cluster를 프로비저닝 및 테스트 하는 방법을 설명 합니다.

#### How to provision

Serverless 타입의 MSK Cluster는 아래와 같이 프로비저닝 합니다.

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
  vpc_id      = "my-vpc-id" # MSK Cluster가 배치될 VPC ID를 입력 합니다.
}

resource "aws_security_group_rule" "client" {
  type              = "ingress"
  description       = "Client to MSK Cluster broker node"
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id
  cidr_blocks       = ["0.0.0.0/0"] # 클라이언트 IP 특정이 가능 한 경우 해당 IP로 대치 합니다.
  from_port         = 9098
  to_port           = 9098
}

module "msk" {
  source                 = "git::https://github.com/oniops/tfmodule-msk.git?ref=v1.0.0"
  context                = module.ctx.context
  cluster_name           = local.cluster_name
  kafka_version          = "3.6.0" 

  # Serverless 타입의 Cluster를 생성 합니다.
  # Serverless는 브로커 노드에 대한 정보 (인스턴스 타입, 노드 개수, 스토리지 볼륨) 를 요구하지 않습니다.
  enable_serverless_cluster = true 
  
  client_subnets         = ["client-subnet-id-1", "client-subnet-id-2"]
  security_groups        = [aws_security_group.this.id]
  enable_client_auth_iam = true
  tags                   = module.ctx.tags
}

# MSK 클러스터 생성이 완료되면 클러스터의 브로커 Endpoint가 출력 됩니다.
output "endpoints" {
  value = module.msk.bootstrap_brokers
}
```

#### How to Test

TODO :: 프로비저닝 후 테스트하는 방법은 모두 같은데 이걸 각 Hands-On 별로 두는게 맞을까?

- 프로비저닝이 완료되면 아래와 같이 토픽의 생성과 Produce, 그리고 Consume을 테스트할 수 있습니다.
- MSK 클러스터 생성이 완료되면 출력되는 클러스터의 브로커 Endpoint를 사용하여 연결 합니다.

먼저 아래의 명령어로 토픽을 생성 합니다.

```sh
kafka_2.13-{YOUR MSK VERSION}/bin/kafka-topics.sh --create \
    --bootstrap-server "{YOUR KAFKA ENDPOINT}" \
    --command-config kafka_2.13-{YOUR MSK VERSION}/config/client.properties
    --replication-factor 2 \
    --partitions 1 \
    --topic "example-topic"
```

토픽이 생성되면 아래와 같이 출력 됩니다.

```sh
Created example-topic
```

다음으로, 아래의 명령어로 생성된 토픽에 메세지를 Produce 합니다.

```sh
kafka_2.13-{YOUR MSK VERSION}/bin/kafka-console-producer.sh \
    --bootstrap-server "{YOUR KAFKA ENDPOINT}" \
    --producer.config kafka_2.13-{YOUR MSK VERSION}/config/client.properties \
    --topic "example-topic"
```

스크립트 실행 후 아래와 같이 CLI에 Produce 할 메세지를 입력 합니다. 메세지 Produce가 끝나면 ctrl+c 를 입력하여 스크립트를 종료 합니다.

```sh
>example-msg-1
>example-msg-2
>^C
```

아래의 명령어를 이용하여 생성된 토픽에 Produce한 메세지를 Consume 합니다.

```sh
kafka_2.13-{YOUR MSK VERSION}/bin/kafka-console-consumer.sh \
    --bootstrap-server "{YOUR KAFKA ENDPOINT}" \
    --consumer.config kafka_2.13-{YOUR MSK VERSION}/config/client.properties \
    --offset latest \
    --topic "example-topic"
```

스크립트 실행 후 아래와 같이 CLI에 Produce 하였던 메세지가 출력 됩니다. 메세지 Consume이 끝나면 ctrl+c 를 입력하여 스크립트를 종료 합니다.

```sh
example-msg-1
example-msg-2
^C
```

# LICENSE
Apache-2.0 Licensed. See [LICENSE](https://github.com/oniops/tfmodule-aws-msk/blob/main/LICENSE).