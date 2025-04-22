# tfmodule-aws-msk
tfmodule-aws-msk is terraform module which creates AWS MSK(Managed Streaming for Apache Kafka) resources
<br>
This module is developed with reference to [terraform-aws-msk-kafka-cluster](https://github.com/terraform-aws-modules/terraform-aws-msk-kafka-cluster) Repository.

## How to clone?
```
git clone https://github.com/oniops/tfmodule-aws-msk.git
cd tfmodule-aws-msk
```

## What is MSK?
Amazon Managed Streaming for Apache Kafka (Amazon MSK) is a fully managed service that enables you to build and run applications that use Apache Kafka to process streaming data. Amazon MSK provides the control-plane operations, such as those for creating, updating, and deleting clusters. It lets you use Apache Kafka data-plane operations, such as those for producing and consuming data. It runs open-source versions of Apache Kafka. This means existing applications, tooling, and plugins from partners and the Apache Kafka community are supported without requiring changes to application code.
<br>
Please refer to [Amazon MSK Developer Guide](https://docs.aws.amazon.com/msk/latest/developerguide/what-is-msk.html) for more details.

## MSK Architecture
TODO :: 여기에 아키텍처 그림이 포함 됩니다

## Resources
The main resources provisioned through the `tfmodule-aws-msk` are described below.

### MSK Cluster
 - MSK Cluster는 메세지 데이터를 저장 및 처리하는 브로커 노드와 메타데이터 관리 노드로 구성됩니다.
 - 메타데이터 관리 모드는 Zookeeper와 Kraft가 있으며, Kraft 모드를 사용하는 경우 메타데이터 관리는 브로커 노드에 통합 됩니다.
 - AWS MSK는 기본적으로 Zookeeper 관리와 유지보수를 자동화하여 사용자가 직접 관리하지 않아도 됩니다.
> Note: Apache Kafka 4.0 버전부터 Zookeeper 노드는 더이상 지원하지 않고, 브로커 노드와 통합된 Kraft 가 메타데이터를 관리 합니다.
- MSk Cluster의 종류에는 `Provisioned`와 `Serverless`타입이 있습니다.
- `Provisioned` 타입은 브로커 인스턴스 유형 및 노드 수, 스토리지 볼륨을 수동으로 구성하고 확장합니다.
- `Serverless` 타입은 클러스터 용량을 관리하고 조정 할 필요 없이 사용할 수 있도록 합니다.

#### Broker
 - 브로커 노드에서는 메세지를 실제로 저장하고 처리합니다.
- `Provisioned` 타입의 MSK Cluster인 경우 브로커의 종류와 타입을 설정해야 합니다.
 - 브로커의 종류에는 `Standard`와 `Express`타입이 있습니다.
 - `Standard` 타입은 스토리지의 볼륨을 수동으로 구성하고 확장하며, 대부분의 클러스터 Configuration을 관리 합니다.
 - `Express` 타입은 스토리지의 볼륨을 자동으로 구성하고 확장하며, 일부의 클러스터 Configuration만 관리 합니다.

#### Available Zone
 - `Provisioned` 타입의 MSK Cluster인 경우 브로커 노드가 배치 될 가용영역을 결정해야 합니다.
 - 브로커 노드는 최소 2개 ~ 최대 3개의 가용영역에 배치되어야 하며, `Express` 타입의 브로커의 경우 3개의 가용영역에 배치되어야 합니다.
 - 각 가용영역에 배치되는 브로커 노드의 개수를 설정할 수 있으며, 최소 1개의 브로커가 각 가용영역에 배치되어야 합니다.

#### Storage
- `Provisioned` 타입의 MSK Cluster에서, 브로커 타입이 `Standard` 인 경우 스토리지 볼륨을 수동으로 구성해야 합니다. `Express` 에서는 자동으로 구성되므로 설정이 불필요 합니다.
- `Provisioned Throuput` 을 이용하여 스토리지의 I/O 성능을 설정할 수 있습니다.
- 계층형 스토리지를 이용하여 일정 시간이 지난 데이터를 저렴한 스토리지로 이동할 수 있습니다. 자세한 내용은 [Amazone MSK 주제에 대해 로그 세그먼트를 계층형 스토리지로 복사 하는 방법](https://docs.aws.amazon.com/ko_kr/msk/latest/developerguide/msk-tiered-storage-retention-rules.html) 문서를 참고 하세요.
- 오토스케일링을 이용하여 스토리지 볼륨 크기를 확장할 수 있습니다. 자세한 내용은 [Amazon MSK 클러스터를 위한 오토 스케일링 설정](https://docs.aws.amazon.com/ko_kr/msk/latest/developerguide/msk-autoexpand-setup.html) 문서를 참고 하세요.
> Note: 스토리지 볼륨 사이즈 조정은 스케일 아웃만 지원하며, 6시간에 한번만 가능 합니다.

#### Subnet
 - MSK Cluster의 브로커 노드가 배치 될 서브넷을 구성 합니다.

#### Security Group
 - MSK Cluster를 위한 보안 그룹을 구성 합니다.
 - Consumer와 Producer 어플리케이션이 클러스터에 접근할 수 있도록 인바운트 트래픽을 허용해야 합니다.

#### Connectivity
 - MSK Cluster의 Public Access 활성화 여부를 결정 합니다.
 - 다른 VPC에 있는 클라이언트가 MSK Cluster에 접근할 수 있도록 설정할 수 있습니다.

#### Authentication
 - 클라이언트가 클러스터에 접근할 때 사용하는 인증 방식을 결정 합니다.
 - 인증은 `noauth`, `sasl/iam`, `sasl/scram` 3가지 방식이 존재 합니다.
 - `noauth` 방식을 사용하면 클라이언트는 인증 없이 클러스터에 접근이 가능 합니다
 - `sasl/iam` 방식을 사용하면 클라이언트는 IAM 정책에 의해서 접근이 제어 됩니다.
 - `sasl/scram` 방식을 사용하면 클라이언트는 등록된 크리덴셜(ID/PW)을 입력하여 접근 합니다.
 - 위 3가지 인증방식과는 별도로 `mTLS` 를 활성화 할 수 있습니다. AWS ACM과 통합하여 클라이언트 연결 시 MSK Cluster에서 클라이언트의 인증서를 검증 합니다.

#### Encryption
 - MSK Cluster 스토리지 및 내/외부에서 통신 시 암호화 여부를 설정 합니다.
 - 스토리지는 KMS 키와 통합되어 암호화 할 수 있습니다.
 - 내/외부 통신의 암호화 유무는 각각 설정할 수 있으며, 설정 시 TLS 암호화 됩니다.

#### Configuration
 - 브로커 노드의 Configuration을 설정 합니다. Configuration은 브로커의 동작을 제어하는 키-값 쌍의 속성 집합입니다.
 - 예를들어, 파티션 수, 메세지 수명주기, Network/Storage IO Thread 수 등을 설정할 수 있습니다.
 - 각 Configuration은 Revision으로 관리 됩니다.

#### Logging & Monitoring
 - MSK Cluster의 리소스 사용량 등의 지표를 Cloudwatch와 통합하여 모니터링 할 수 있습니다. `Provisioned` 타입의 MSK Cluster에서 브로커 타입이 `Standard`인 경우 통합 시 Level을 설정하여 더 디테일한 대상 매트릭 설정이 가능합니다. 자세한 내용은 [CloudWatch를 사용하여 표준 브로커 머니터링을 위한 Amazone MSK 지표](https://docs.aws.amazon.com/ko_kr/msk/latest/developerguide/metrics-details.html) 문서를 참고하세요.
 - MSK Cluster의 모니터링은 Prometheus와 통합될 수 있습니다. 자세한 내용은 [Promethus를 사용하여 MSK Provisioned Cluster 모니터링](https://docs.aws.amazon.com/ko_kr/msk/latest/developerguide/open-monitoring.html) 문서를 참고하세요/
 - 로그는 Cloudwatch Log Groups, Firehose, S3와 통합될 수 있습니다.

## Variables
`tfmodule-aws-msk` 모듈에서 사용되는 Input / Output 변수에 대한 설명 입니다.
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
        <td>MSK Cluster의 생성 유무를 결정 합니다.</td>
        <td>bool</td>
        <td>true</td>
        <td>no</td>
        <td>false</td>
    </tr>
    <tr>
        <td>cluster_tags</td>
        <td>MSK Cluster 리소스에 대한 태그를 설정 합니다.</td>
        <td>map(string)</td>
        <td>null</td>
        <td>no</td>
        <td>{Name = "My-MSK-Cluster", Onwer = "Me"}</td>
    </tr>
    <tr>
        <td>tags</td>
        <td>MSK Cluster 외 리소스에 대한 태그를 설정 합니다.</td>
        <td>map(string)</td>
        <td>null</td>
        <td>no</td>
        <td>{Name = "My-Autoscaling", Onwer = "Me"}</td>
    </tr>
    <tr>
        <td>enable_serverless_cluster</td>
        <td>MSK Cluster의 타입을 설정 합니다. true인 경우 Provisioned, false인 경우 Serverless 타입으로 생성 됩니다.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>false</td>
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
        <td>Allow or not access from public to broker.</td>
        <td>string</td>
        <td>"DISABLED"</td>
        <td>no</td>
        <td>"DISABLED" means that public access is turned off. "SERVICE_PROVIDED_EIPS" means that public access is turned on</td>
    </tr>
    <tr>
        <td>instance_type</td>
        <td>Specify the instance type to use for the kafka brokers. e.g. kafka.m5.large.</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
        <td>See: <a href="https://aws.amazon.com/msk/pricing/">Pricing Info</a></td>
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
        <td>EBS Storage volumes size attached to MSK broker nodes. min: 1, max: 16384, unit: GiB</td>
        <td>number</td>
        <td>1000</td>
        <td>no</td>
        <td>512</td>
    </tr>
    <tr>
        <td>enable_provisioned_throughput</td>
        <td>Provisioned throughput is enabled or not.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>provisioned_volume_throughput</td>
        <td>Throughput value of the EBS volumes for the data drive on each kafka broker node in MiB per second.</td>
        <td>number</td>
        <td>250</td>
        <td>no</td>
        <td>500</td>
    </tr>
    <tr>
        <td>enable_client_noauth</td>
        <td>Allow or not client access without authentication.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>enable_client_auth_iam</td>
        <td>SASL/IAM authentication is enabled or not.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>enable_client_auth_scram</td>
        <td>SASL/SCRAM authentication is enabled or not.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>client_auth_cert_authority_arns</td>
        <td>List of AWS Private CA Amazon Resource Name (ARN)s. If listed, client checks broker's certificates.</td>
        <td>list(string)</td>
        <td>null</td>
        <td>no</td>
        <td>["arn:aws:acm:ap-northeast-2:111122223333:certificate/a1b2c3d4-a1b2-c3d4-e5f6-112233445566"]</td>
    </tr>
    <tr>
        <td>cluster_name</td>
        <td>Name of the MSK cluster.</td>
        <td>string</td>
        <td></td>
        <td>yes</td>
        <td>"my-cluster"</td>
    </tr>
    <tr>
        <td>cluster_fullname</td>
        <td>Fullname of the MSK cluster.</td>
        <td>string</td>
        <td></td>
        <td>yes</td>
        <td>"my-cluster-full-name"</td>
    </tr>
    <tr>
        <td>encryption_at_rest_kms_key_arn</td>
        <td>You may specify a KMS key short ID or ARN (it will always output an ARN) to use for encrypting your data at rest. If no key is specified, an AWS managed KMS ('aws/msk' managed service) key will be used for encrypting the data at rest</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
        <td>"arn:aws:kms:ap-northeast-2:111122223333:key/012ab345-ab12-3344-a556-112233445566"</td>
    </tr>
    <tr>
        <td>encryption_in_transit_client_broker</td>
        <td>Encryption setting for data in transit between clients and brokers.</td>
        <td>string</td>
        <td>"TLS"</td>
        <td>no</td>
        <td>"TLS", "TLS_PLAINTEXT", and "PLAINTEXT"</td>
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
        <td>enhanced_monitoring</td>
        <td>Specify the desired enhanced MSK CloudWatch monitoring level.</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
        <td>Available options are "DEFAULT" | "PER_BROKER" | "PER_TOPIC_PER_BROKER" | "PER_TOPIC_PER_PARTITION". See <a href="https://docs.aws.amazon.com/msk/latest/developerguide/monitoring.html">Monitoring Amazon MSK with Amazon CloudWatch</a></td>
    </tr>
    <tr>
        <td>kafka_version</td>
        <td>Specify the desired Kafka software version.</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
        <td>"3.6.0"</td>
    </tr>
    <tr>
        <td>cloudwatch_log_group_tags</td>
        <td>A map of additional tags to add to the cloudwatch log group created.</td>
        <td>map(string)</td>
        <td>null</td>
        <td>no</td>
        <td>{Name = "My-Cloudwatch-Loggroup", Onwer = "Me"}</td>
    </tr>
    <tr>
        <td>cloudwatch_log_group_class</td>
        <td>Specifies the log class of the log group.</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
        <td>Possible values are: "STANDARD" or "INFREQUENT_ACCESS".</td>
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
        <td>"my-kinesis-stream"</td>
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
        <td>false</td>
        <td>no</td>
        <td>"my-s3-bucket"</td>
    </tr>
    <tr>
        <td>s3_logs_prefix</td>
        <td>Prefix to append to the folder name.</td>
        <td>string</td>
        <td>false</td>
        <td>no</td>
        <td>"msk-cluster/my-cluster/logs"</td>
    </tr>
    <tr>
        <td>number_of_broker_nodes</td>
        <td>The desired total number of broker nodes in the kafka cluster. It must be a multiple of the number of specified client subnets.</td>
        <td>number</td>
        <td>null</td>
        <td>no</td>
        <td>1</td>
    </tr>
    <tr>
        <td>jmx_exporter_enabled</td>
        <td>Indicates whether you want to enable or disable the JMX Exporter.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>node_exporter_enabled</td>
        <td>Indicates whether you want to enable or disable the Node Exporter.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>storage_mode</td>
        <td>Controls storage mode for supported storage tiers.</td>
        <td>string</td>
        <td>"LOCAL"</td>
        <td>no</td>
        <td>"LOCAL" or "TIERED"</td>
    </tr>
    <tr>
        <td>enable_vpc_connectivity</td>
        <td>Whether to use multiple VPC Connection. See <a href="https://docs.aws.amazon.com/msk/latest/developerguide/aws-access-mult-vpc.html">document</a></td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>vpc_connectivity_auth_tls</td>
        <td>Enables TLS authentication for VPC connectivity.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>vpc_connectivity_auth_iam</td>
        <td>Enables SASL/IAM authentication for VPC connectivity.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>vpc_connectivity_auth_scram</td>
        <td>Enables SASL/SCRAM authentication for VPC connectivity.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>create_configuration</td>
        <td>Determines whether to create a configuration.</td>
        <td>bool</td>
        <td>true</td>
        <td>no</td>
        <td>false</td>
    </tr>
    <tr>
        <td>configuration_arn</td>
        <td>ARN of an externally created configuration to use.</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
        <td>"arn:aws:kafka:ap-northeast-2:370166107047:configuration/dev-an2d-platform-mskcfg/11112222-3333-4444-5555-666677778888-1"</td>
    </tr>
    <tr>
        <td>configuration_name</td>
        <td>Specify cluster configuration name.</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
        <td>"my-msk-config"</td>
    </tr>
    <tr>
        <td>configuration_revision</td>
        <td>Revision of the externally created configuration to use.</td>
        <td>number</td>
        <td>null</td>
        <td>no</td>
        <td>2</td>
    </tr>
    <tr>
        <td>configuration_description</td>
        <td>Description of the configuration.</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
        <td>"This Configuration is for my-msk-cluster"</td>
    </tr>
    <tr>
        <td>configuration_kafka_versions</td>
        <td>Support Kafka version.</td>
        <td>list(string)</td>
        <td>null</td>
        <td>no</td>
        <td>["3.6.0"]</td>
    </tr>
    <tr>
        <td>configuration_server_properties</td>
        <td>Contents of the server.properties file.</td>
        <td>map(string)</td>
        <td>{}</td>
        <td>no</td>
        <td>Supported properties are documented in the <a href="https://docs.aws.amazon.com/msk/latest/developerguide/msk-configuration-properties.html">MSK Developer Guide</a></td>
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
    <tr>
        <td>enable_storage_autoscaling</td>
        <td>Determines whether autoscaling is enabled for storage.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>scaling_max_size</td>
        <td>Max storage size for Kafka broker autoscaling.</td>
        <td>number</td>
        <td>250</td>
        <td>no</td>
        <td>300</td>
    </tr>
    <tr>
        <td>scaling_target_value</td>
        <td>The Kafka broker storage utilization at which scaling is initiated.</td>
        <td>number</td>
        <td>70</td>
        <td>no</td>
        <td>50</td>
    </tr>
</tbody>
</table>

### Output Variables
TODO :: 여기에 Output 변수 테이블이 구성 됩니다.

## Hands-On
TODO :: 여기에 아래와 같은 클러스터 생성에 관한 코드가 구성 됩니다.
 - Provisioned-Standard
    기본 구성 방법 및 테스트 방법
    Autoscaling 구성 방법 및 테스트 방법
    Tiered Storage 및 테스트 방법
 - Provisioned-Express
    기본 구성 방법 및 테스트 방법
 - 모니터링 레벨 설정 및 로그 통합 방법 및 테스트 방법
 - Serverless
   기본 구성 방법 및 테스트 방법