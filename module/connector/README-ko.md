# tfmodule-aws-msk/connector

tfmodule-aws-msk/connector는 AWS MSK Connector 리소스를 생성하는 Terraform 모듈입니다.

## How to clone

```sh
git clone https://github.com/oniops/tfmodule-aws-msk.git
cd tfmodule-aws-msk/module/connector
```

## Context
이 모듈은 tfmodule-context Terraform 모듈을 사용하여 서비스 및 리소스를 정의하며, AWS 모범 사례(Best Practice) 모델에 따라 표준화된 네이밍 정책과 태그 규칙을 제공하고, 일관된 데이터 소스 참조 모듈을 제공합니다.
<br>
Context에 관한 자세한 내용은 Terraform 모듈 [tfmodule-context](https://github.com/oniops/tfmodule-context) 을 참고해주세요.

## Usage

MSK Connector에 대한 자세한 내용은 [AWS 가이드문서](https://docs.aws.amazon.com/ko_kr/msk/latest/developerguide/msk-connect.html) 문서를 참고하세요.

### Example

다음은 MySQL Debezium 플러그인을 사용하여 MySQL 데이터베이스의 특정 테이블 변경 사항을 캡처하고, 이를 토픽 메시지로 생산하는 커넥터(Connector)를 생성하는 예시입니다.

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
  kafkaconnect_version = "2.7.1"                                      # Kafka 클러스터 버전과 호환되는 버전으로 지정해야 합니다.
  cluster_name         = "my-msk-cluster-name"                        # 대상 Kafka 클러스터 이름입니다.
  subnet_ids           = ["subnet-001122334455", "subnet-66778899aa"] # MSK 커넥터가 배포될 서브넷입니다.
  security_groups      = ["sg-001122334455", "sg-66778899aa"]         # MSK 커넥터에 연결될 보안 그룹입니다. Kafka 브로커 노드 및 대상 데이터베이스에 접근할 수 있어야 합니다.
  bootstrap_servers    = ["msk-broker-node-server-1:9096", "msk-broker-node-server-2:9096"] # 연결할 Kafka 브로커 노드의 주소입니다.
  authentication_type  = "NONE"      # Kafka 브로커 노드에 연결할 때 사용하는 클라이언트 인증 방식입니다. 이 예시는 인증 없이 연결합니다.
  encryption_type      = "PLAINTEXT" # Kafka 브로커 노드와의 통신에서 TLS 암호화를 사용할지 여부입니다. 이 예시는 암호화 없이 평문 통신을 사용합니다.
  s3_bucket_arn        = "arn:aws:s3:::my-plugin-s3-bucket-arn" # MySQL Debezium 플러그인이 업로드된 S3 버킷의 ARN입니다.
  s3_file_key          = "path/to/mysql-debezium-plugin.zip"    # MySQL Debezium 플러그인이 업로드된 S3 버킷 내 경로입니다.
  
  connector_configuration = {
    "connector.class"       = "io.debezium.connector.mysql.MySqlConnector"
    "tasks.max"             = "1"
    "database.hostname"     = "my-database-hostname" # MySQL 데이터베이스의 연결 주소입니다.
    "database.port"         = "3306"                 # MySQL 데이터베이스의 연결 포트입니다.
    "database.user"         = "HAVE TO CHANGE"       # MySQL 데이터베이스 인증 시 사용할 사용자 이름입니다.
    "database.password"     = "HAVE TO CHANGE"       # MySQL 데이터베이스 인증 시 사용할 사용자 비밀번호입니다.
    "database.server.id"    = "123456"               # MySQL 데이터베이스에 대한 고유 번호입니다. 다른 커넥터와 충돌되지 않도록 1부터 2^32-1 사이의 임의의 정수로 설정하세요.
    "database.include.list" = "my-database"          # 데이터를 캡처할 대상 데이터베이스의 이름입니다.
  }
}
```

## Variables

이 장에서는 tfmodule-aws-msk/connector에서 사용되는 입력(Input) 및 출력(Output) 변수에 대해 설명합니다.

### [Input Variables](https://oniops.github.io/tfmodule-aws-msk/readme-connector-input-variables-ko.html)

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
            <td>MSK Connector 리소스 생성 유무를 결정 합니다.</td>
            <td>bool</td>
            <td>true</td>
            <td>no</td>
            <td>false</td>
        </tr>
        <tr>
            <td>context</td>
            <td>이 모듈은 tfmodule-context Terraform 모듈을 사용하여 서비스 및 리소스를 정의하며, 표준화된 네이밍 정책, 태그 지정 규칙, 일관된 데이터 소스 참조 모듈을 제공합니다. Context에 대한 자세한 내용은 <a href="https://github.com/oniops/tfmodule-context">tfmodule-context</a> 모듈을 참고하세요.</td>
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
            <td>이 모듈에서 생성되는 리소스에 대해 추가 태그를 지정하세요. 모든 리소스에 적용되는 기본 태그는 Context 값에 따라 결정됩니다. 변수 "tags" 에 대한 내용은 Context 모듈 <a href="https://github.com/oniops/tfmodule-context">tfmodule-context</a> 을 참고하세요.</td>
            <td>map(string)</td>
            <td>null</td>
            <td>no</td>
            <td>{Timestamp = "20101231", CompanyURL = "https://my-company-url.com"}</td>
        </tr>
        <tr>
            <td>create_connector_role</td>
            <td>MSK Connect 역할을 생성할지 여부를 결정합니다. false로 설정한 경우, MSK 커넥터의 IAM 역할로 사용할 "service_exec_role_arn"을 직접 입력해야 합니다.</td>
            <td>bool</td>
            <td>true</td>
            <td>no</td>
            <td>false</td>
        </tr>
        <tr>
            <td>service_exec_role_arn</td>
            <td>커넥터가 필요한 Amazon Web Services 리소스에 접근하기 위해 사용하는 IAM 역할의 ARN(Amazon Resource Name)입니다. 필요한 리소스의 유형은 커넥터의 동작 방식에 따라 달라집니다. 예를 들어, Amazon S3를 대상으로 하는 커넥터는 S3 대상 버킷에 쓰기 권한이 있어야 합니다.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"arn:aws:iam::111122223333:role/myConnectorRole"</td>
        </tr>
        <tr>
            <td>service_exec_role_description</td>
            <td>Connector Service Execution 역할에 대한 설명 입니다.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"This is myConnectorRole"</td>
        </tr>
        <tr>
            <td>service_exec_role_permissions_boundary</td>
            <td>커넥터 서비스 실행 IAM 역할에 대한 권한 경계(Permissions Boundary)를 설정하는 데 사용되는 정책의 ARN입니다.</td>
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
            <td>커넥터 서비스 실행 IAM 역할에 추가로 연결할 정책(Policy) 목록입니다.</td>
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
            <td>MSK Connector의 설명 입니다.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"This is my-msk-connector"</td>
        </tr>
        <tr>
            <td>connector_name</td>
            <td>MSK Connector의 이름을 지정합니다. 이름 형식은 Context 값에 따라 결정됩니다. "name_prefix" 변수에 대한 내용은 Context 모듈 <a href="https://github.com/oniops/tfmodule-context">tfmodule-context</a> 을 참고하세요.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"my-msk-connector"</td>
        </tr>
        <tr>
            <td>connector_name</td>
            <td>MSK Connector의 전체 이름(Fullname)을 지정합니다. Context 값에 따라 자동 생성된 형식을 사용하지 않으려는 경우, 이 값을 직접 지정할 수 있습니다.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"my-msk-connector-fullname"</td>
        </tr>
        <tr>
            <td>kafkaconnect_version</td>
            <td>사용하려는 Kafka 소프트웨어 버전을 지정하세요. 해당 버전은 Kafka 클러스터와 호환되는 버전이어야 합니다.</td>
            <td>string</td>
            <td></td>
            <td>yes</td>
            <td>"2.7.1"</td>
        </tr>
        <tr>
            <td>connector_configuration</td>
            <td>커넥터에 대한 Configuration을 나타내는 키-값 쌍의 맵(Map)입니다.</td>
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
            <td>연결 될 MSK 클러스터 이름 입니다.</td>
            <td>string</td>
            <td></td>
            <td>yes</td>
            <td>"my-msk-cluster"</td>
        </tr>
        <tr>
            <td>bootstrap_servers</td>
            <td>연결할 Kafka 클러스터의 브로커 엔드포인트를 쉼표로 구분한 문자열입니다.</td>
            <td>string</td>
            <td></td>
            <td>yes</td>
            <td>"broker-endpoint-1:9092,broker-endpoint-2:9092"</td>
        </tr>
        <tr>
            <td>subnet_ids</td>
            <td>MSK Connector를 배치할 서브넷 목록입니다.</td>
            <td>list(string)</td>
            <td></td>
            <td>yes</td>
            <td>["subnet-111122223333","subnet-aaaabbbbcccc"]</td>
        </tr>
        <tr>
            <td>security_groups</td>
            <td>MSK Connector에 적용할 보안 그룹 목록입니다.</td>
            <td>list(string)</td>
            <td></td>
            <td>yes</td>
            <td>["sg-001122334455", "sg-66778899aa"]</td>
        </tr>
        <tr>
            <td>encryption_type</td>
            <td>Kafka 클러스터의 전송 중 암호화(Encryption in transit) 설정입니다. TLS 또는 PLAINTEXT 중 하나를 선택하세요.</td>
            <td>string</td>
            <td>"TLS"</td>
            <td>no</td>
            <td>"PLAINTEXT"</td>
        </tr>
        <tr>
            <td>authentication_type</td>
            <td>Kafka 클러스터의 클라이언트 인증 설정입니다. IAM 또는 NONE 중 하나를 선택하세요.</td>
            <td>string</td>
            <td>"IAM"</td>
            <td>no</td>
            <td>"NONE"</td>
        </tr>
        <tr>
            <td>enable_autoscaling</td>
            <td>오토스케일링을 활성화할지 여부를 설정합니다. 이 설정은 "Provisioned" 유형의 MSK Connector에만 적용됩니다.</td>
            <td>bool</td>
            <td>false</td>
            <td>no</td>
            <td>true</td>
        </tr>
        <tr>
            <td>autoscaling_mcu_count</td>
            <td>프로비저닝된 용량에 할당할 MCU(MSK Connect Unit)의 개수입니다. 1 MCU는 1 vCPU와 4GiB 메모리로 구성됩니다.</td>
            <td>number</td>
            <td>1</td>
            <td>no</td>
            <td>3</td>
        </tr>
        <tr>
            <td>autoscaling_min_worker_count</td>
            <td>오토스케일링을 위한 최소 작업자(Worker) 수입니다.</td>
            <td>number</td>
            <td>1</td>
            <td>no</td>
            <td>3</td>
        </tr>
        <tr>
            <td>autoscaling_max_worker_count</td>
            <td>오토스케일링을 위한 최대 작업자(Worker) 수입니다./td>
            <td>number</td>
            <td>2</td>
            <td>no</td>
            <td>5</td>
        </tr>
        <tr>
            <td>scale_in_cpu_utilization_percentage</td>
            <td>스케일 인(축소)을 위한 CPU 사용률 임계값(%)입니다.</td>
            <td>number</td>
            <td>20</td>
            <td>no</td>
            <td>30</td>
        </tr>
        <tr>
            <td>scale_out_cpu_utilization_percentage</td>
            <td>스케일 아웃(확장)을 위한 CPU 사용률 임계값(%) 입니다.</td>
            <td>number</td>
            <td>80</td>
            <td>no</td>
            <td>70</td>
        </tr>
        <tr>
            <td>provisioned_capacity_mcu_count</td>
            <td>프로비저닝된 용량에 할당할 MCU(MSK Connect Unit)의 수입니다.</td>
            <td>number</td>
            <td>1</td>
            <td>no</td>
            <td>3</td>
        </tr>
        <tr>
            <td>provisioned_capacity_worker_count</td>
            <td>프로비저닝된 용량에 할당할 작업자(Worker)의 수입니다. 작업자는 MSK Connector의 태스크를 실행합니다.</td>
            <td>number</td>
            <td>1</td>
            <td>no</td>
            <td>3</td>
        </tr>
        <tr>
            <td>cloudwatch_logs_enabled</td>
            <td>로그를 CloudWatch Logs로 스트리밍할지 여부를 설정합니다.</td>
            <td>bool</td>
            <td>true</td>
            <td>no</td>
            <td>false</td>
        </tr>
        <tr>
            <td>firehose_logs_enabled</td>
            <td>Connector 로그를 Kinesis Data Firehose로 스트리밍할지 여부를 설정합니다.</td>
            <td>bool</td>
            <td>false</td>
            <td>no</td>
            <td>true</td>
        </tr>
        <tr>
            <td>firehose_delivery_stream</td>
            <td>로그를 전달할 Kinesis Data Firehose 딜리버리 스트림의 이름입니다.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"my-firehose-stream"</td>
        </tr>
        <tr>
            <td>s3_logs_enabled</td>
            <td>Connector 로그를 S3로 스트리밍할지 여부를 설정합니다.</td>
            <td>bool</td>
            <td>false</td>
            <td>no</td>
            <td>true</td>
        </tr>
        <tr>
            <td>s3_logs_bucket</td>
            <td>로그를 전달할 S3 버킷의 이름입니다.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"my-s3-bucket"</td>
        </tr>
        <tr>
            <td>s3_logs_prefix</td>
            <td>S3 버킷 이름에 추가할 접두사(Prefix)입니다.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"path/to/s3/logs"</td>
        </tr>
        <tr>
            <td>create_cloudwatch_log_group</td>
            <td>CloudWatch 로그 그룹을 생성할지 여부를 결정합니다.</td>
            <td>bool</td>
            <td>true</td>
            <td>no</td>
            <td>false</td>
        </tr>
        <tr>
            <td>cloudwatch_log_group_name</td>
            <td>로그를 전달할 CloudWatch 로그 그룹의 이름입니다.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"my-cloudwatch-log-group"</td>
        </tr>
        <tr>
            <td>cloudwatch_log_group_retention_in_days</td>
            <td>로그 그룹에서 로그 이벤트를 보관할 일 수를 지정합니다.</td>
            <td>number</td>
            <td>14</td>
            <td>no</td>
            <td>21</td>
        </tr>
        <tr>
            <td>cloudwatch_log_group_kms_key_id</td>
            <td>로그 데이터를 암호화할 때 사용할 KMS 키의 ARN입니다.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"arn:aws:kms:ap-northeast-2:111122223333:key/000ab111-cd23-4455-a667-78899aabbccddef"</td>
        </tr>
        <tr>
            <td>cloudwatch_log_group_class</td>
            <td>로그 그룹의 **로그 클래스(Log Class)**를 지정합니다. 사용 가능한 값: STANDARD 또는 INFREQUENT_ACCESS</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"STANDARD"</td>
        </tr>
        <tr>
            <td>create_worker_configuration</td>
            <td>Worker Configuration을 생성할지 여부를 결정합니다./td>
            <td>bool</td>
            <td>true</td>
            <td>no</td>
            <td>false</td>
        </tr>
        <tr>
            <td>worker_configuration_name</td>
            <td>Worker Configuration의 이름 입니다.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"my-worker-config-name"</td>
        </tr>
        <tr>
            <td>worker_configuration_fullname</td>
            <td>Worker Configuration의 full name 입니다.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"my-worker-config-fullname"</td>
        </tr>
        <tr>
            <td>worker_configuration_description</td>
            <td>Worker Configuration의 설명 입니다.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"This is my-worker-config"</td>
        </tr>
        <tr>
            <td>properties_file_content</td>
            <td>MSK Connect에서 작업자(Worker)를 구성하기 위한 설정입니다. 이 설정들은 작업자의 동작 방식, 데이터 변환 방식, Kafka 클러스터와의 통신 방식을 결정합니다.</td>
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
            <td>MSK Connect에서 사용할 Custom Plugin 이름입니다.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"my-connector-plugin-name"</td>
        </tr>
        <tr>
            <td>plugin_fullname</td>
            <td>MSK Connect에서 사용할 Custom Plugin의 full name입니다.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"my-connector-plugin-fullname"</td>
        </tr>
        <tr>
            <td>plugin_description</td>
            <td>Custom Plugin의 설명 입니다.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"This is my-connector-plugin"</td>
        </tr>
        <tr>
            <td>content_type</td>
            <td>플러그인 파일의 콘텐츠 유형을 지정합니다. 예: ZIP, JAR</td>
            <td>string</td>
            <td>"ZIP"</td>
            <td>no</td>
            <td>"JAR"</td>
        </tr>
        <tr>
            <td>s3_bucket_arn</td>
            <td>플러그인 콘텐츠가 저장된 **S3 버킷의 Amazon Resource Name (ARN)**입니다.</td>
            <td>string</td>
            <td></td>
            <td>yes</td>
            <td>"arn:aws:s3:::my-plugin-s3-bucket-arn"</td>
        </tr>
        <tr>
            <td>s3_file_key</td>
            <td>플러그인이 포함된 S3 버킷 내의 파일 경로(Key)입니다.</td>
            <td>string</td>
            <td></td>
            <td>yes</td>
            <td>"path/to/custom/plugin"</td>
        </tr>
        <tr>
            <td>plugin_arn</td>
            <td>Custom Plugin의 ARN 입니다.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"arn:aws:kafkaconnect:us-east-1:123456789012:custom-plugin/mysql-debezium/abcdefgh-1234-5678-9abc-defghijklmno"</td>
        </tr>
        <tr>
            <td>plugin_revision</td>
            <td>사용할 Custom Plugin의 특정 리비전 또는 버전 식별자입니다.</td>
            <td>string</td>
            <td>null</td>
            <td>no</td>
            <td>"3"</td>
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
            <td>MSK Connector의 ARN 입니다.</td>
            <td>string</td>
            <td>"arn:aws:kafkaconnect:us-east-1:123456789012:connector/my-connector/abcdefgh-1234-5678-9abc-defghijklmno"</td>
        </tr>
        <tr>
            <td>custom_plugin_arn</td>
            <td>Custom plugin의 ARN 입니다.</td>
            <td>string</td>
            <td>"arn:aws:kafkaconnect:us-east-1:123456789012:custom-plugin/mysql-debezium/abcdefgh-1234-5678-9abc-defghijklmno"</td>
        </tr>
        <tr>
            <td>worker_configuration_arn</td>
            <td>Worker configuration의 ARN 입니다.</td>
            <td>string</td>
            <td>"arn:aws:kafkaconnect:us-east-1:123456789012:worker-configuration/my-worker-config/abcdefgh-1234-5678-9abc-defghijklmno"</td>
        </tr>
    </tbody>
</table>

# LICENSE

- Apache-2.0 [LICENSE](https://github.com/oniops/tfmodule-aws-msk/blob/main/LICENSE).
- 이 모듈은 [terraform-aws-msk-kafka-cluster](https://github.com/terraform-aws-modules/terraform-aws-msk-kafka-cluster) 모듈을 커스터마이징 하였습니다. 또한 해당 모듈의 라이선스 정책을 그대로 따릅니다.