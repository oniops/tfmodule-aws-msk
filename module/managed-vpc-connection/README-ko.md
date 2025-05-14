# tfmodule-aws-msk/managed-vpc-connection

tfmodule-aws-msk/managed-vpc-connection는 AWS MSK Managed VPC connection 리소스를 생성하는 Terraform 모듈입니다.
## How to clone

```sh
git clone https://github.com/oniops/tfmodule-aws-msk.git
cd tfmodule-aws-msk/module/managed-vpc-connection
```

## Context
이 모듈은 tfmodule-context Terraform 모듈을 사용하여 MSK 서비스 및 리소스를 정의하며, AWS 모범 사례(Best Practice) 모델에 따라 표준화된 네이밍 정책과 태그 규칙을 제공하고, 일관된 데이터 소스 참조 모듈을 제공합니다.
<br>
Context에 관한 자세한 내용은 Terraform 모듈 [tfmodule-context](https://github.com/oniops/tfmodule-context) 을 참고해주세요.

## Usage

Managed VPC Connection에 대한 자세한 내용은 [AWS 가이드문서](https://docs.aws.amazon.com/ko_kr/msk/latest/developerguide/mvpc-getting-started.html?icmpid=docs_console_unmapped) 를 참고하세요.

### Example

다음은 MSK 클러스터가 배포된 VPC가 아닌 다른 VPC에서 클라이언트가 MSK 클러스터에 접근할 수 있도록 허용하는 Managed VPC 연결을 생성하는 예시입니다.

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

module "connection" {
  source             = "git::https://github.com/oniops/tfmodule-aws-msk.git//module/managed-vpc-connection?ref=v1.0.0"
  context            = var.context
  target_cluster_arn = "arn:aws:kafka:ap-northeast-2:123456789012:cluster/my-msk-cluster/abc12d3e-1234-5678-9012-95de01ee639c-s1"
  authentication     = "SASL_IAM"                   # 다른 VPC에서 접근하는 클라이언트를 위해 MSK 클러스터가 사용하는 인증 방식을 입력하세요.
  vpc_id             = "client-vpc-id"              # 접근하는 클라이언트가 배포된 VPC ID를 입력하세요.
  security_groups    = ["client-security-group-id"] # 접근하는 클라이언트의 보안 그룹 ID를 입력하세요.
  client_subnets     = ["client-subnet-id-1", "client-subnet-id-2"] # 접근하는 클라이언트가 사용하는 서브넷 ID를 입력하세요.
}
```

## Variables

이 장에서는 tfmodule-aws-msk/managed-vpc-connection 에서 사용되는 입력(Input) 및 출력(Output) 변수에 대해 설명합니다.

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
            <td>Managed VPC Connection 리소스 생성 유무를 결정 합니다.</td>
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
            <td>target_cluster_arn</td>
            <td>연결 대상 MSK 클러스터의 Amazon Resource Name (ARN) 입니다.</td>
            <td>string</td>
            <td></td>
            <td>yes</td>
            <td>"arn:aws:kafka:ap-northeast-2:123456789012:cluster/my-source-msk-cluster/abc12d3e-1234-5678-9012-95de01ee639c-s1"</td>
        </tr>
        <tr>
            <td>vpc_id</td>
            <td>클라이언트의 VPC ID입니다.</td>
            <td>string</td>
            <td></td>
            <td>yes</td>
            <td>"vpc-1234abcd"</td>
        </tr>
        <tr>
            <td>client_subnets</td>
            <td>클라이언트 VPC에서 연결할 서브넷 목록입니다.</td>
            <td>list(string)</td>
            <td></td>
            <td>yes</td>
            <td>["subnet-111122223333aaaab"]</td>
        </tr>
        <tr>
            <td>security_groups</td>
            <td>브로커 노드의 ENI에 연결할 보안 그룹(Security Group) 목록입니다. MSK 클러스터는 이 보안 그룹을 통해 접근할 수 있도록 허용해야 합니다.</td>
            <td>list(string)</td>
            <td></td>
            <td>yes</td>
            <td>["sg-111122223333abcda"]</td>
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
            <td>Managed VPC connection의 ARN 입니다.</td>
            <td>string</td>
            <td>"arn:aws:kafka:ap-northeast-2:123456789012:vpc-connection/my-vpc-connection/abc123def456ghi789"</td>
        </tr>
    </tbody>
</table>

# LICENSE

- Apache-2.0 [LICENSE](https://github.com/oniops/tfmodule-aws-msk/blob/main/LICENSE).
- 이 모듈은 [terraform-aws-msk-kafka-cluster](https://github.com/terraform-aws-modules/terraform-aws-msk-kafka-cluster) 모듈을 커스터마이징 하였습니다. 또한 해당 모듈의 라이선스 정책을 그대로 따릅니다.