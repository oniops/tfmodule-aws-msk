# tfmodule-aws-msk

tfmodule-aws-msk는 AWS MSK(Managed Streaming for Apache Kafka) 리소스를 생성하는 Terraform 모듈입니다.

## How to clone

```sh
git clone https://github.com/oniops/tfmodule-aws-msk.git
cd tfmodule-aws-msk
```

## Context
이 모듈은 tfmodule-context Terraform 모듈을 사용하여 MSK 서비스 및 리소스를 정의하며, AWS 모범 사례(Best Practice) 모델에 따라 표준화된 네이밍 정책과 태그 규칙을 제공하고, 일관된 데이터 소스 참조 모듈을 제공합니다.
<br>
Context에 관한 자세한 내용은 Terraform 모듈 [tfmodule-context](https://github.com/oniops/tfmodule-context) 을 참고해주세요.

## Usage

### Example 1 : Provisioned MSK Cluster - Standard Type Broker
Provisioned MSK Cluster - Standard Type Broker에 대한 자세한 내용은 [AWS 가이드 문서](https://docs.aws.amazon.com/ko_kr/msk/latest/developerguide/msk-broker-types-standard.html) 를 참고해주세요.
<br>
이 장에서는 프로비저닝된(provisioned) 유형의 MSK 클러스터에서 표준(Standard) 유형의 브로커 노드를 생성(provision)하는 방법을 설명합니다. 브로커 노드에 대한 클라이언트 인증 방식은 SASL/IAM입니다.

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
  vpc_id      = "my-vpc-id" # MSK Cluster 가 배치 될 VPC ID를 입력하세요.
}

resource "aws_security_group_rule" "client" {
  type              = "ingress"
  description       = "Client to MSK Cluster broker node"
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id
  cidr_blocks       = ["10.0.0.0/16"] # VPC CIDR 블록은 cidr_blocks로 권장됩니다. 만약 클라이언트 IP를 지정할 수 있다면 해당 IP를 입력하세요.
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
  client_subnets         = ["client-subnet-id-1", "client-subnet-id-2"] # MSK Cluster가 배치될 서브넷 입니다.
  ebs_volume_size        = 1000
  security_groups        = [aws_security_group.this.id]
}

# MSK 클러스터가 생성된 후, 브로커 노드의 엔드포인트가 표시됩니다.
output "endpoints" {
  value = module.msk.bootstrap_brokers
}
```
#### SASL/IAM Authentication

브로커 노드에 연결하기 위한 SASL/IAM 인증* IAM 정책(IAM Policy)에 의해 제어됩니다. 예를 들어, 필요한 정책은 다음과 같습니다:

- Sid: AllowMSKAccess : MSK 클러스터에 연결하기 위한 권한을 부여하는 정책
- Sid: AllowMSKConsume : 토픽에서 메시지를 소비(consume)할 수 있는 권한을 부여하는 정책
- Sid: AllowMSKProduce : 토픽에 메시지를 생산(produce)할 수 있는 권한을 부여하는 정책
- Sid: AllowMSKTopicAccess : 토픽의 설정을 읽거나 토픽을 생성/삭제할 수 있는 권한을 부여하는 정책
- Sid: AllowMSKGroupAccess : 컨슈머 그룹을 읽거나 생성할 수 있는 권한을 부여하는 정책

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
Provisioned MSK Cluster - Express Type Broker에 대한 자세한 내용은 [AWS 가이드 문서](https://docs.aws.amazon.com/ko_kr/msk/latest/developerguide/msk-broker-types-express.html) 를 참고해주세요.
[this AWS Documentation]().
<br>
이 장에서는 프로비저닝된(provisioned) 유형의 MSK 클러스터에서 Express 유형의 브로커 노드를 생성(provision)하는 방법을 설명합니다. 브로커 노드에 대한 클라이언트 인증 방식은 SASL/IAM입니다.

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
  vpc_id      = "my-vpc-id" # MSK Cluster 가 배치 될 VPC ID를 입력하세요.
}

resource "aws_security_group_rule" "client" {
  type              = "ingress"
  description       = "Client to MSK Cluster broker node"
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id
  cidr_blocks       = ["10.0.0.0/16"] # VPC CIDR 블록은 cidr_blocks로 권장됩니다. 만약 클라이언트 IP를 지정할 수 있다면 해당 IP를 입력하세요.
  from_port         = 9098
  to_port           = 9098
}

module "msk" {
  source                 = "git::https://github.com/oniops/tfmodule-aws-msk.git?ref=v1.0.0"
  context                = module.ctx.context
  cluster_name           = local.cluster_name
  enable_client_auth_iam = true
  kafka_version          = "3.6.0"
  
  # Express 유형의 브로커 노드를 사용하려면 express.* 형식의 인스턴스를 입력하세요.
  instance_type          = "express.m7g.large"

  # MSK 클러스터를 배치할 서브넷 ID를 입력하세요. Express 유형의 경우, 최소 3개의 가용 영역(Availability Zones)이 필요합니다.  
  client_subnets         = ["client-subnet-id-1", "client-subnet-id-2", "client-subnet-id-3"] 
  number_of_broker_nodes = 3

  ebs_volume_size        = 1000
  security_groups        = [aws_security_group.this.id]
}

# MSK 클러스터가 생성된 후, 브로커 노드의 엔드포인트가 표시됩니다.
output "endpoints" {
  value = module.msk.bootstrap_brokers
}
```

Express 유형의 브로커 노드에서 지원되는 인스턴스 타입은 다음과 같습니다 :

- express.m7g.large
- express.m7g.xlarge
- express.m7g.2xlarge
- express.m7g.4xlarge
- express.m7g.8xlarge
- express.m7g.12xlarge
- express.m7g.16xlarge

<br>

### Example 3 : Serverless MSK Cluster
Serverless MSK Cluster 에 대한 자세한 내용은 [this AWS Documentation](https://docs.aws.amazon.com/ko_kr/msk/latest/developerguide/serverless.html).
<br>
이 장에서는 서버리스(Serverless) 유형의 MSK 클러스터를 생성(provision)하는 방법을 설명합니다. 브로커 노드에 대한 클라이언트 인증 방식은 SASL/IAM입니다.

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
  vpc_id      = "my-vpc-id" # MSK Cluster 가 배치 될 VPC ID를 입력하세요.
}

resource "aws_security_group_rule" "client" {
  type              = "ingress"
  description       = "Client to MSK Cluster broker node"
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id
  cidr_blocks       = ["10.0.0.0/16"] # VPC CIDR 블록은 cidr_blocks로 권장됩니다. 만약 클라이언트 IP를 지정할 수 있다면 해당 IP를 입력하세요.
  from_port         = 9098
  to_port           = 9098
}

module "msk" {
  source                 = "git::https://github.com/oniops/tfmodule-aws-msk.git?ref=v1.0.0"
  context                = module.ctx.context
  cluster_name           = local.cluster_name
  kafka_version          = "3.6.0"

  # 서버리스(Serverless) 유형의 MSK 클러스터 생성
  # 서버리스 유형의 MSK 클러스터는 인스턴스 타입, 노드 수, 스토리지 용량을 별도로 설정할 필요가 없습니다.
  enable_serverless_cluster = true 
  
  client_subnets         = ["client-subnet-id-1", "client-subnet-id-2"]
  security_groups        = [aws_security_group.this.id]
  enable_client_auth_iam = true
}

# MSK 클러스터가 생성된 후, 브로커 노드의 엔드포인트가 표시됩니다.
output "endpoints" {
  value = module.msk.bootstrap_brokers
}
```

## Variables

이 장에서는 tfmodule-aws-msk에서 사용되는 입력(Input) 및 출력(Output) 변수에 대해 설명합니다.

### [Input Variables](https://oniops.github.io/tfmodule-aws-msk/readme-cluster-input-variables-ko.html)

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
        <td>MSK 클러스터 리소스를 생성할지 여부를 설정합니다.</td>
        <td>bool</td>
        <td>true</td>
        <td>no</td>
        <td>false</td>
    </tr>
    <tr>
        <td>context</td>
        <td>이 모듈은 tfmodule-context Terraform 모듈을 사용하여 MSK 서비스 및 리소스를 정의하며, 표준화된 네이밍 정책, 태그 지정 규칙, 일관된 데이터 소스 참조 모듈을 제공합니다. Context에 대한 자세한 내용은 <a href="https://github.com/oniops/tfmodule-context">tfmodule-context</a> 모듈을 참고하세요.</td>
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
        <td>MSK 클러스터의 이름을 지정합니다. 이름 형식은 Context 값에 따라 결정됩니다. "name_prefix" 변수에 대한 내용은 Context 모듈 <a href="https://github.com/oniops/tfmodule-context">tfmodule-context</a> 을 참고하세요.</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
        <td>"my-cluster"</td>
    </tr>
    <tr>
        <td>cluster_fullname</td>
        <td>MSK 클러스터의 전체 이름(Fullname)을 지정합니다. Context 값에 따라 자동 생성된 형식을 사용하지 않으려는 경우, 이 값을 직접 지정할 수 있습니다.</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
        <td>"my-cluster-full-name"</td>
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
        <td>enable_serverless_cluster</td>
        <td>MSK 클러스터의 배포 유형을 지정하세요. true로 설정하면 Serverless 유형으로 설정됩니다. false로 설정하면 Provisioned 유형으로 설정됩니다.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>false</td>
    </tr>
    <tr>
        <td>kafka_version</td>
        <td>(클러스터 유형 - Provisioned 전용) 사용하려는 Kafka 소프트웨어 버전을 지정하세요. 지원되는 버전은 문서 <a href="https://docs.aws.amazon.com/ko_kr/msk/latest/developerguide/supported-kafka-versions.html"> 이 문서</a> 를 참고하세요.</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
        <td>"3.6.0"</td>
    </tr>    
    <tr>
        <td>client_subnets</td>
        <td>클라이언트 VPC에서 연결할 서브넷 목록을 지정합니다. 자세한 내용은 <a href="https://docs.aws.amazon.com/msk/1.0/apireference/clusters.html#clusters-prop-brokernodegroupinfo-clientsubnets">이 문서</a> 를 참고하세요.</td>
        <td>list(string)</td>
        <td></td>
        <td>yes</td>
        <td>["subnet-1111aaaa2222bbbb3", "subnet-4444cccc5555dddd6"]</td>
    </tr>
    <tr>
        <td>public_access_type</td>
        <td>브로커에 대한 퍼블릭 액세스를 허용할지 여부를 설정합니다. "DISABLED" : 퍼블릭 액세스가 비활성화됩니다. "SERVICE_PROVIDED_EIPS" : 퍼블릭 액세스가 활성화되며, 서비스에서 제공하는 EIP를 사용합니다.</td>
        <td>string</td>
        <td>"DISABLED"</td>
        <td>no</td>
        <td>"DISABLED" or "SERVICE_PROVIDED_EIPS"</td>
    </tr>
    <tr>
        <td>instance_type</td>
        <td>(클러스터 유형 - Provisioned 전용) Kafka 브로커에 사용할 인스턴스 타입을 지정하세요. 인스턴스 타입에 의해 브로커의 타입 (Standard / Express)이 결정됩니다. 참고 : <a href="https://aws.amazon.com/msk/pricing/">MSK Broker 인스턴스 타입</a></td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
        <td>"kafka.t3.small"</td>
    </tr>
    <tr>
        <td>number_of_broker_nodes</td>
        <td>(클러스터 유형 - Provisioned 전용) Kafka 클러스터에서 원하는 브로커 노드의 총 개수입니다. 이 수는 사용 가능한 가용 영역의 수와 같거나 배수여야 합니다.</td>
        <td>number</td>
        <td>null</td>
        <td>no</td>
        <td>1</td>
    </tr>    
    <tr>
        <td>security_groups</td>
        <td>클러스터와 통신할 수 있는 대상을 제어하기 위해 탄력적 네트워크 인터페이스에 연결할 보안 그룹 목록입니다.</td>
        <td>list(string)</td>
        <td>null</td>
        <td>no</td>
        <td>["sg-111122223333", "sg-444455556666"]</td>
    </tr>
    <tr>
        <td>ebs_volume_size</td>
        <td>(클러스터 유형 - Provisioned / Standard 브로커 노드 전용) Standard 유형의 MSK 브로커 노드에 연결되는 EBS 스토리지 볼륨 크기입니다. 스토리지는 확장(Scale-out)만 가능하며, 축소(Scale-in)는 불가능합니다. 사용 가능한 크기: 최소 1, 최대 16384 (단위: GiB)</td>
        <td>number</td>
        <td>1000</td>
        <td>no</td>
        <td>512</td>
    </tr>
    <tr>
        <td>enable_provisioned_throughput</td>
        <td>(클러스터 유형 - Provisioned / Standard 브로커 노드 전용) 프로비저닝된 처리량을 활성화할지 여부입니다. 이 옵션을 활성화하면 스토리지 I/O 성능을 설정할 수 있습니다.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>provisioned_volume_throughput</td>
        <td>(클러스터 유형 - Provisioned / Standard 브로커 노드 전용) 각 Kafka 브로커 노드의 데이터 드라이브에 대한 스토리지 I/O 성능의 처리량 값입니다. 단위는 초당 MiB(MiB/s)입니다.</td>
        <td>number</td>
        <td>250</td>
        <td>no</td>
        <td>500</td>
    </tr>
    <tr>
        <td>enable_storage_autoscaling</td>
        <td>(클러스터 유형 - Provisioned / Standard 브로커 노드 전용) 스토리지에 대한 오토스케일링을 활성화할지 여부를 결정합니다. 오토스케일링은 스토리지의 확장(Scale-out)에만 적용됩니다. 스토리지는 6시간에 한 번만 확장할 수 있습니다.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>scaling_max_size</td>
        <td>(클러스터 유형 - Provisioned / Standard 브로커 노드 전용) Kafka 브로커 오토스케일링을 위한 최대 스토리지 크기입니다.</td>
        <td>number</td>
        <td>250</td>
        <td>no</td>
        <td>300</td>
    </tr>
    <tr>
        <td>scaling_target_value</td>
        <td>(클러스터 유형 - Provisioned / Standard 브로커 노드 전용) 스케일링이 트리거 되는 Kafka 브로커 스토리지 사용률입니다.</td>
        <td>number</td>
        <td>70</td>
        <td>no</td>
        <td>50</td>
    </tr>    
    <tr>
        <td>create_configuration</td>
        <td>(클러스터 유형 - Provisioned 전용) MSK 클러스터 Configuration을 생성할지 여부를 결정합니다.</td>
        <td>bool</td>
        <td>true</td>
        <td>no</td>
        <td>false</td>
    </tr>
    <tr>
        <td>configuration_arn</td>
        <td>(클러스터 유형 - Provisioned 전용) 사용할 외부에서 생성된 Configuration의 ARN입니다.</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
        <td>"arn:aws:kafka:ap-northeast-2:111122223333:configuration/dev-an2d-platform-mskcfg/11112222-3333-4444-5555-666677778888-1"</td>
    </tr>
    <tr>
        <td>configuration_name</td>
        <td>(클러스터 유형 - Provisioned 전용) 클러스터 Configuration 이름 입니다.</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
        <td>"my-msk-config"</td>
    </tr>
    <tr>
        <td>configuration_revision</td>
        <td>(클러스터 유형 - Provisioned 전용) 생성 된 클러스터 Configuration의 사용 Revision 입니다.</td>
        <td>number</td>
        <td>null</td>
        <td>no</td>
        <td>2</td>
    </tr>
    <tr>
        <td>configuration_description</td>
        <td>(클러스터 유형 - Provisioned 전용) 클러스터 Configuration의 설명 입니다.</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
        <td>"This Configuration is for my-msk-cluster"</td>
    </tr>
    <tr>
        <td>configuration_kafka_versions</td>
        <td>(클러스터 유형 - Provisioned 전용) 클러스터 Configuration이 지원하는 Kafka 버전 입니다.</td>
        <td>list(string)</td>
        <td>null</td>
        <td>no</td>
        <td>["3.6.0"]</td>
    </tr>
    <tr>
        <td>configuration_server_properties</td>
        <td>(클러스터 유형 - Provisioned 전용) server.properties 파일에 추가 될 속성 입니다. 지원하는 속성값은 다음 문서를 참고하세요 : <a href="https://docs.aws.amazon.com/msk/latest/developerguide/msk-configuration-properties.html">MSK Developer Guide</a></td>
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
        <td>클라이언트가 인증 없이 MSK 브로커 노드에 접근하여 소비(consume) 또는 생산(produce) 등의 작업을 수행할 수 있도록 허용할지 여부입니다.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>enable_client_auth_iam</td>
        <td>클라이언트가 MSK 브로커 노드에 접근하여 소비(consume) 또는 생산(produce) 등의 작업을 수행할 때 SASL/IAM 인증을 활성화할지 여부입니다. 활성화된 경우, 접근 권한은 클라이언트(서비스 또는 애플리케이션)에 연결된 AWS IAM에 의해 제어됩니다.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>enable_client_auth_scram</td>
        <td>클라이언트가 MSK 브로커 노드에 접근하여 소비(consume) 또는 생산(produce) 등의 작업을 수행할 때 SASL/SCRAM 인증을 활성화할지 여부입니다. 활성화된 경우, 접근 권한은*로그인(ID/비밀번호)을 통해 제어되며, AWS Secrets Manager와 통합하여 사용할 수 있습니다.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>client_auth_cert_authority_arns</td>
        <td>AWS ACM의 ARN 목록입니다. 해당 목록이 지정되면, 브로커는 클라이언트의 인증서를 검사합니다(Mutual TLS).</td>
        <td>list(string)</td>
        <td>null</td>
        <td>no</td>
        <td>["arn:aws:acm:ap-northeast-2:111122223333:certificate/a1b2c3d4-a1b2-c3d4-e5f6-112233445566"]</td>
    </tr>
    <tr>
        <td>encryption_at_rest_kms_key_arn</td>
        <td>MSK 브로커 노드 스토리지에 저장된 데이터를 암호화하기 위해 사용할 KMS 키의 짧은 ID 또는 ARN을 지정하세요. 항상 ARN 형식으로 출력됩니다. 키를 지정하지 않으면, AWS에서 관리하는 KMS 키인 'aws/msk' 관리형 서비스 키가 데이터 암호화에 사용됩니다.</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
        <td>"arn:aws:kms:ap-northeast-2:111122223333:key/012ab345-ab12-3344-a556-112233445566"</td>
    </tr>
    <tr>
        <td>encryption_in_transit_client_broker</td>
        <td>클라이언트와 브로커 간 데이터 전송 시의 암호화 설정입니다. 유효한 값: TLS, TLS_PLAINTEXT, PLAINTEXT. TLS : 브로커는 TLS 암호화 전송만 허용합니다. TLS_PLAINTEXT : 브로커는 TLS 암호화 전송과 일반 전송을 모두 허용합니다. PLAINTEXT : 브로커는 일반 전송만 허용합니다.</td>
        <td>string</td>
        <td>"TLS"</td>
        <td>no</td>
        <td>"TLS_PLAINTEXT"</td>
    </tr>
    <tr>
        <td>encryption_in_transit_in_cluster</td>
        <td>브로커 노드 간의 데이터 통신이 암호화되는지 여부입니다.</td>
        <td>bool</td>
        <td>true</td>
        <td>no</td>
        <td>false</td>
    </tr>
    <tr>
        <td>create_scram_secret_association</td>
        <td>SASL/SCRAM 시크릿 연결(Secret Association)을 생성할지 여부를 결정합니다.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>scram_secret_list</td>
        <td>SCRAM과 연동할 AWS Secrets Manager 시크릿 ARN 목록입니다.</td>
        <td>list(string)</td>
        <td>[]</td>
        <td>no</td>
        <td>["arn:aws:secretsmanager:ap-northeast-2:111122223333:secret:mysecret-1", "arn:aws:secretsmanager:ap-northeast-2:111122223333:secret:mysecret-2"]</td>
    </tr>
    <tr>
        <td>storage_mode</td>
        <td>지원되는 스토리지 계층에 대한 스토리지 모드를 제어합니다. Standard 유형의 브로커에서는 티어드 스토리지(Tiered Storage)를 통해 오래된 데이터를 저비용 스토리지로 이전할 수 있습니다. 사용 가능한 값: "LOCAL" 또는 "TIERED". 자세한 내용은 <a href="https://docs.aws.amazon.com/ko_kr/msk/latest/developerguide/msk-tiered-storage.html">MSK Tiered storage for Standard broker</a> 를 참고하세요.</td>
        <td>string</td>
        <td>"LOCAL"</td>
        <td>no</td>
        <td>"TIERED"</td>
    </tr>
    <tr>
        <td>enable_vpc_connectivity</td>
        <td>다중 VPC 연결(Multiple VPC Connection)을 사용할지 여부입니다. 다른 VPC에 연결된 클라이언트에서 MSK 클러스터에 접근하려면, VPC 연결(VPC Connectivity)이 활성화되어 있어야 합니다. 자세한 내용은 <a href="https://docs.aws.amazon.com/msk/latest/developerguide/aws-access-mult-vpc.html">가이드 문서</a> 를 참고하세요.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>vpc_connectivity_auth_tls</td>
        <td>VPC 연결에 대해 TLS 인증을 활성화할지 여부입니다. 활성화된 경우, 다른 VPC에서 접근하는 클라이언트의 인증서를 브로커가 검사합니다(Mutual TLS).</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>vpc_connectivity_auth_iam</td>
        <td>다른 VPC에서 MSK 브로커 노드에 접근하여 소비(consume) 또는 생산(produce) 등의 작업을 수행할 때 SASL/IAM 인증을 활성화할지 여부입니다. 활성화된 경우, 접근 권한은 클라이언트(서비스 또는 애플리케이션)에 연결된 AWS IAM에 의해 제어됩니다.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>vpc_connectivity_auth_scram</td>
        <td>다른 VPC에서 MSK 브로커 노드에 접근하여 소비(consume) 또는 생산(produce) 등의 작업을 수행할 때 SASL/SCRAM 인증을 활성화할지 여부입니다. 활성화된 경우, 접근 권한은 로그인(ID/비밀번호)을 통해 제어되며, AWS Secrets Manager와 통합하여 사용할 수 있습니다.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>    
    <tr>
        <td>enhanced_monitoring</td>
        <td>원하는 MSK CloudWatch 모니터링 수준을 지정합니다. 이 설정을 통해 MSK 클러스터 및 브로커의 메트릭 상세 수준을 조절할 수 있습니다. 사용 가능한 옵션: "DEFAULT" | "PER_BROKER" | "PER_TOPIC_PER_BROKER" | "PER_TOPIC_PER_PARTITION". 자세한 내용은 <a href="https://docs.aws.amazon.com/msk/latest/developerguide/monitoring.html">Monitoring Amazon MSK with Amazon CloudWatch.</a>를 참고하세요.</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
        <td>"PER_BROKER"</td>
    </tr>
    <tr>
        <td>cloudwatch_logs_enabled</td>
        <td>브로커 로그를 CloudWatch Logs로 스트리밍할지 여부를 설정합니다.</td>
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
        <td>로그 그룹의 로그 클래스(Log Class)를 지정합니다. 사용 가능한 값: "STANDARD" 또는 "INFREQUENT_ACCESS"</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>firehose_delivery_stream</td>
        <td>MSK 브로커 노드 로그를 Kinesis Data Firehose로 스트리밍할지 여부를 설정합니다.</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
        <td>"my-kinesis-stream"</td>
    </tr>
    <tr>
        <td>s3_logs_enabled</td>
        <td>MSK 브로커 노드 로그를 S3로 스트리밍할지 여부를 설정합니다.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>s3_logs_bucket</td>
        <td>MSK 브로커 노드 로그를 전달할 S3 버킷의 이름입니다.</td>
        <td>string</td>
        <td>false</td>
        <td>no</td>
        <td>"my-s3-bucket"</td>
    </tr>
    <tr>
        <td>s3_logs_prefix</td>
        <td>MSK 브로커 노드 로그의 버킷 객체 이름에 추가할 접두사(Prefix) 입니다.</td>
        <td>string</td>
        <td>false</td>
        <td>no</td>
        <td>"msk-cluster/my-cluster/logs"</td>
    </tr>
    <tr>
        <td>jmx_exporter_enabled</td>
        <td>Prometheus용 JMX Exporter를 활성화할지 비활성화할지 여부를 설정합니다.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
    </tr>
    <tr>
        <td>node_exporter_enabled</td>
        <td>Prometheus용 Node Exporter를 활성화할지 비활성화할지 여부를 설정합니다.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
        <td>true</td>
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
        <td>"my-cw-loggroup-name"</td>
    </tr>
    <tr>
        <td>cloudwatch_log_group_retention_in_days</td>
        <td>로그 그룹에서 로그를 보관할 일 수를 지정합니다.</td>
        <td>number</td>
        <td>14</td>
        <td>no</td>
        <td>7</td>
    </tr>
    <tr>
        <td>cloudwatch_log_group_kms_key_id</td>
        <td>로그 데이터를 암호화할 때 사용할 KMS 키의 ARN입니다.</td>
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
        <td>MSK 클러스터의 ARN 입니다.</td>
        <td>string</td>
        <td>"arn:aws:kafka:us-east-1:111122223333:cluster/demomsk/11112222-3344-5566-7788-152f5289c6dd-14"</td>
    </tr>
    <tr>
        <td>cluster_name</td>
        <td>MSK 클러스터의 이름 입니다.</td>
        <td>string</td>
        <td>"my-msk-cluster"</td>
    </tr>
    <tr>
        <td>cluster_uuid</td>
        <td>IAM Policy에서 일반적으로 사용되는 MSK 클러스터의 UUID 입니다./td>
        <td>string</td>
        <td>"11112222-3344-5566-7788-152f5289c6dd-14"</td>
    </tr>    
    <tr>
        <td>bootstrap_brokers_plaintext</td>
        <td>Kafka 클러스터에 대한 연결을 부트스트랩하는 데 사용할 수 있는 하나 이상의 kafka 브로커의 hostname:port 쌍을 쉼표로 구분한 목록입니다. 이 값은 encryption_in_transit_client_broker가 PLAINTEXT 또는 TLS_PLAINTEXT로 설정된 경우에 포함됩니다.</td>
        <td>list(string)</td>
        <td>["b-1.demomsk.112233.c14.kafka.us-east-1.amazonaws.com:9092","b-2.demomsk.445566.c14.kafka.us-east-1.amazonaws.com:9092"]</td>
    </tr>
    <tr>
        <td>bootstrap_brokers_sasl_iam</td>
        <td>하나 이상의 DNS 이름(또는 IP 주소)과 SASL IAM 포트 쌍입니다. 이 속성은 encryption_in_transit_client_broker가 TLS_PLAINTEXT 또는 TLS로 설정되고, client_authentication_sasl_iam이 true로 설정된 경우에 값을 가집니다.</td>
        <td>list(string)</td>
        <td>["b-1.demomsk.112233.c14.kafka.us-east-1.amazonaws.com:9098","b-2.demomsk.445566.c14.kafka.us-east-1.amazonaws.com:9098"]</td>
    </tr>
    <tr>
        <td>bootstrap_brokers_sasl_scram</td>
        <td>하나 이상의 DNS 이름(또는 IP 주소)과 SASL SCRAM 포트 쌍입니다. 이 속성은 `encryption_in_transit_client_broker`가 `TLS_PLAINTEXT` 또는 `TLS`로 설정되고, `client_authentication_sasl_scram`이 `true`로 설정된 경우에 값을 가집니다.</td>
        <td>list(string)</td>
        <td>["b-1.demomsk.112233.c14.kafka.us-east-1.amazonaws.com:9096","b-2.demomsk.445566.c14.kafka.us-east-1.amazonaws.com:9096"]</td>
    </tr>
    <tr>
        <td>bootstrap_brokers_tls</td>
        <td>하나 이상의 DNS 이름(또는 IP 주소)과 TLS 포트 쌍입니다. 이 속성은 `encryption_in_transit_client_broker`가 `TLS_PLAINTEXT` 또는 `TLS`로 설정된 경우에 값을 가집니다.</td>
        <td>list(string)</td>
        <td>["b-1.demomsk.112233.c14.kafka.us-east-1.amazonaws.com:9094","b-2.demomsk.445566.c14.kafka.us-east-1.amazonaws.com:9094"]</td>
    </tr>
    <tr>
        <td>bootstrap_brokers</td>
        <td>Kafka 클러스터에 대한 연결을 위한 하나 이상의 kafka 브로커의 `hostname:port` 쌍을 쉼표로 구분한 주소 목록입니다.</td>
        <td>list(string)</td>
        <td>["b-1.demomsk.112233.c14.kafka.us-east-1.amazonaws.com:9092","b-2.demomsk.445566.c14.kafka.us-east-1.amazonaws.com:9098"]</td>
    </tr>
    <tr>
        <td>bootstrap_brokers_authentication</td>
        <td>클라이언트 인증을 위한 브로커 인증 방식의 이름 문자열입니다. `SASL_IAM` : IAM 인증, `SASL_SCRAM` : SASL/SCRAM 인증, `TLS` : Mutual TLS 인증</td>
        <td>string</td>
        <td>"SASL_IAM"</td>
    </tr>
    <tr>
        <td>zookeeper_connect_string</td>
        <td>Apache Zookeeper 연결에 사용할 하나 이상의 `hostname:port` 쌍을 쉼표로 구분한 주소 목록입니다. 반환되는 값은 알파벳 순으로 정렬됩니다.</td>
        <td>list(string)</td>
        <td>["z-3.demomsk.aabbcc.c14.kafka.us-east-1.amazonaws.com:2181","z-1.demomsk.11aabb.c14.kafka.us-east-1.amazonaws.com":2181,"z-2.demomsk.abcd1234.c14.kafka.us-east-1.amazonaws.com:2181"]</td>
    </tr>
    <tr>
        <td>zookeeper_connect_string_tls</td>
        <td>Apache Zookeeper 클러스터에 TLS를 통해 연결할 때 사용할 하나 이상의 `hostname:port` 쌍을 쉼표로 구분한 주소 목록입니다. 반환되는 값은 알파벳 순으로 정렬됩니다.</td>
        <td>list(string)</td>
        <td>["z-3.demomsk.aabbcc.c14.kafka.us-east-1.amazonaws.com:2182","z-1.demomsk.11aabb.c14.kafka.us-east-1.amazonaws.com":2182,"z-2.demomsk.abcd1234.c14.kafka.us-east-1.amazonaws.com:2182"]</td>
    </tr>
    <tr>
        <td>configuration_arn</td>
        <td>MSK 클러스터 Configuration의 ARN 입니다.</td>
        <td>string</td>
        <td>"arn:aws:kafka:us-east-1:111122223333:configuration/demomskcfg/1234abcd-1111-2222-33aa-aaaabbbbcccc-14"</td>
    </tr>
    <tr>
        <td>configuration_latest_revision</td>
        <td>MSK 클러스터 Configuration의 최신 Revision 입니다.</td>
        <td>string</td>
        <td>"7"</td>
    </tr>
    <tr>
        <td>scram_secret_association_id</td>
        <td>MSK SCRAM secret 연결의 ID 입니다.</td>
        <td>string</td>
        <td>"arn:aws:kafka:us-east-1:111122223333:cluster/demomsk/abcd1234-abcd-5678-abcd-1234abcd5678-1/scram-secret-association/efgh5678-ijkl-9012-mnop-3456qrst7890"</td>
    </tr>
    <tr>
        <td>log_group_arn</td>
        <td>Cloudwatch log group의 ARN 입니다.</td>
        <td>string</td>
        <td>"arn:aws:logs:us-east-1:111122223333:log-group:/msk/demomsk"</td>
    </tr>
    <tr>
        <td>appautoscaling_policy_arn</td>
        <td>Autoscaling Policy의 ARN 입니다.</td>
        <td>string</td>
        <td>"arn:aws:autoscaling:us-east-1:111122223333:scalingPolicy:11112222-3333-aabb-4444-555566667777:resource/msk/default/demomsk:pplocyName/my-as-policy-name"</td>
    </tr>
    <tr>
        <td>appautoscaling_policy_name</td>
        <td>Autoscaling Policy의 이름 입니다.</td>
        <td>string</td>
        <td>"my-as-policy-name"</td>
    </tr>
</tbody>
</table>

# Appendix

## How to connect to MSK

MSK 클러스터 연결 테스트를 위해서는 kafka-script를 사전에 준비해야 합니다.

<br>

먼저, Java를 설치 합니다.

```sh
sudo yum -y install java-11
```

그런 다음, Apache Kafka에서 제공하는 Kafka 관리 스크립트를 다운로드합니다. MSK 클러스터의 Kafka 버전을 `{YOUR MSK VERSION}`에 입력하세요.

```sh
wget https://archive.apache.org/dist/kafka/{YOUR MSK VERSION}/kafka_2.13-{YOUR MSK VERSION}.tgz
```

예를 들어, Apache Kafka 버전이 3.6.0인 경우 아래와 같이 명령어를 입력 합니다.

```sh
wget https://archive.apache.org/dist/kafka/3.6.0/kafka_2.13-3.6.0.tgz
```

다운받은 TGZ 파일의 압축을 해제 합니다.

```sh
tar -xzf kafka_2.13-{YOUR MSK VERSION}.tgz
```

`kafka_2.13-{YOUR MSK VERSION}/config` 디렉토리로 이동한 후 연결에 사용될 인증에 관한 정보가 포함 될 `client.properties` 파일을 생성 합니다.

```sh
cd kafka_2.13-{YOUR MSK VERSION}/config
touch client.properties
```

`client.properties` 파일의 내용은 클라이언트 인증 방식에 따라 다음과 같이 작성됩니다.
<br>
클라이언트 인증 방식이 NOAUTH(`enable_client_noauth == true`)인 경우, `security.protocol=PLAINTEXT`로 설정합니다.

```sh
security.protocol=SASL_SSL
```

`consumer group`을 지정하고 싶다면, 다음과 같은 속성으로 설정할 수 있습니다 :
```sh
group.id={CONSUMER GROUP ID}
```

클라이언트 인증 방식이 SASL/IAM(`enable_client_auth_iam == true`)인 경우, 먼저 `kafka_2.13-{YOUR MSK VERSION}/libs` 디렉터리로 이동한 후, 아래 명령어를 실행하여 Amazon MSK IAM JAR 파일을 다운로드합니다.

```sh
cd kafka_2.13-{YOUR MSK VERSION}/libs
wget https://github.com/aws/aws-msk-iam-auth/releases/download/v2.3.0/aws-msk-iam-auth-2.3.0-all.jar
```

다음으로, `client.properties` 파일을 작성합니다.
<br>
클라이언트와 브로커가 암호화되지 않은 통신을 할 경우, `security.protocol=PLAINTEXT`로 설정합니다.

```sh
security.protocol=SASL_SSL
sasl.mechanism=AWS_MSK_IAM
sasl.jaas.config=software.amazon.msk.auth.iam.IAMLoginModule required;
sasl.client.callback.handler.class=software.amazon.msk.auth.iam.IAMClientCallbackHandler
```

클라이언트 인증 방식이 SASL/SCRAM(`enable_client_auth_scram == true`)인 경우, 다음과 같이 설정합니다.
<br>
클라이언트와 브로커가 암호화되지 않은 통신을 할 경우, `security.protocol=PLAINTEXT`로 설정합니다.

```sh
security.protocol=SASL_SSL
sasl.mechanism=SCRAM-SHA-512
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required username="{USERNAME}" password="{PASSWORD}";
```

마지막으로, 아래 명령어를 사용하여 클러스터에 성공적으로 연결되고 토픽 목록을 조회할 수 있는지 확인합니다.

```sh
kafka_2.13-{YOUR MSK VERSION}/bin/kafka-topics.sh --list \
    --bootstrap-server "{YOUR KAFKA ENDPOINT}" \
    --command-config kafka_2.13-{YOUR MSK VERSION}/config/client.properties
```

예시 결과는 아래와 같습니다.

```sh
MSKTutorialTopic
TestTopic
__amazon_msk_canary
__consumer_offsets
```

## How to test topic

토픽을 생성하고, 메시지를 생산(produce)하며, 소비(consume)하는 방법은 다음과 같습니다. 먼저, 아래 명령어로 토픽을 생성합니다.

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

생성된 토픽으로 메세지를 생산 하기 위해 아래의 명령어를 실행 합니다.

```sh
kafka_2.13-{YOUR MSK VERSION}/bin/kafka-console-producer.sh \
    --bootstrap-server "{YOUR KAFKA ENDPOINT}" \
    --producer.config kafka_2.13-{YOUR MSK VERSION}/config/client.properties \
    --topic "example-topic"
```

스크립트를 실행한 후, 아래와 같이 CLI에 전송할 메시지를 입력합니다. 메시지 전송이 완료되면 Ctrl + C를 눌러 스크립트를 종료합니다.

```sh
>example-msg-1
>example-msg-2
>^C
```

해당 토픽에서 메세지를 소비 하기 위해서는 아래와 같이 명령어를 실행 합니다.

```sh
kafka_2.13-{YOUR MSK VERSION}/bin/kafka-console-consumer.sh \
    --bootstrap-server "{YOUR KAFKA ENDPOINT}" \
    --consumer.config kafka_2.13-{YOUR MSK VERSION}/config/client.properties \
    --from-beginning \
    --topic "example-topic"
```

스크립트를 실행하면, CLI에서 생산한 메시지가 아래와 같이 출력됩니다. 메시지 소비가 완료되면 Ctrl + C를 눌러 스크립트를 종료합니다.

```sh
example-msg-1
example-msg-2
^C
```

## How to check importance values

Kafka 브로커의 몇가지 주요한 항목에 대해서 확인하는 방법을 설명 합니다.

### Offset

consumer group을 지정하기 위해서는 먼저 `client.properties` 파일의 `group.id` 속성을 확인 하세요.
자세한 내용은 [How to connect to MSK](#How-to-connect-to-MSK) 를 참고 하세요.

```
group.id={CONSUMER GROUP ID}
```

아래 명령어를 실행하여 offset을 확인 합니다.

```sh
kafka_2.13-{YOUR MSK VERSION}/bin/kafka-consumer-groups.sh \
    --bootstrap-server "{YOUR KAFKA ENDPOINT}" \
    --command-config kafka_2.13-{YOUR MSK VERSION}/config/client.properties \
    --describe \
    --group "{CONSUMER GROUP ID}"
```

명령어를 실행하면 아래와 같이 출력 됩니다.

```sh
GROUP                 TOPIC           PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG             CONSUMER-ID     HOST            CLIENT-ID
{CONSUMER GROUP ID}   example-topic   0          2               2               0               -               -               -
```

offset을 변경하려면 아래의 명령어를 실행 합니다.

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

변경된 offset을 아래의 명령어로 확인 합니다.

```sh
kafka_2.13-{YOUR MSK VERSION}/bin/kafka-consumer-groups.sh \
    --bootstrap-server "{YOUR KAFKA ENDPOINT}" \
    --command-config kafka_2.13-{YOUR MSK VERSION}/config/client.properties \
    --describe \
    --group "{CONSUMER GROUP ID}"
```

출력은 다음과 같습니다.

```sh
GROUP                 TOPIC           PARTITION  CURRENT-OFFSET      LOG-END-OFFSET  LAG             CONSUMER-ID     HOST            CLIENT-ID
{CONSUMER GROUP ID}   example-topic   0          {OFFSET TO CHANGE}  2               0               -               -               -
```


### Partition

토픽의 파티션을 확인하기 위해서는 아래의 명령어를 실행 합니다.

```sh
kafka_2.13-{YOUR MSK VERSION}/bin/kafka-topics.sh \
    --bootstrap-server "{YOUR KAFKA ENDPOINT}" \
    --describe
```

출력은 다음과 같습니다.

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
 - Apache-2.0 [LICENSE](https://github.com/oniops/tfmodule-aws-msk/blob/main/LICENSE).
 - 이 모듈은 [terraform-aws-msk-kafka-cluster](https://github.com/terraform-aws-modules/terraform-aws-msk-kafka-cluster) 모듈을 커스터마이징 하였습니다. 또한 해당 모듈의 라이선스 정책을 그대로 따릅니다.