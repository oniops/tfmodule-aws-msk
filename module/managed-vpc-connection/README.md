# tfmodule-aws-msk/managed-vpc-connection

tfmodule-aws-msk/managed-vpc-connection is Terraform module which creates AWS MSK Managed VPC connection.

## How to clone

```sh
git clone https://github.com/oniops/tfmodule-aws-msk.git
cd tfmodule-aws-msk/module/managed-vpc-connection
```

## Context
This module uses the tfmodule-context Terraform module to define MSK services and resources, providing a standardized naming policy and tagging conventions for AWS Best Practice model, and a consistent datasource reference module. For more information about Context, see the <a href="https://github.com/oniops/tfmodule-context">tfmodule-context</a> Terraform module.

## Usage

### Example

This is an example of creating a Managed VPC connection to allow clients to access the MSK Cluster from a VPC other than the one where the MSK Cluster is deployed.

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
  authentication     = "SASL_IAM"                   # Enter the authentication method that the MSK Cluster uses for clients accessing from other VPCs.
  vpc_id             = "client-vpc-id"              # Enter the VPC ID where the accessing client is deployed.
  security_groups    = ["client-security-group-id"] # Enter the Security Group ID of the accessing client.
  client_subnets     = ["client-subnet-id-1", "client-subnet-id-2"] # Enter the Subnet ID used by the accessing client.
}
```

## Variables

Describes the Input/Output variables used in tfmodule-aws-msk/managed-vpc-connection.

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
            <td>Determines whether Managed VPC Connection resources will be created.</td>
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
            <td>target_cluster_arn</td>
            <td>The Amazon Resource Name (ARN) of the cluster to connect to.</td>
            <td>string</td>
            <td></td>
            <td>yes</td>
            <td>"arn:aws:kafka:ap-northeast-2:123456789012:cluster/my-source-msk-cluster/abc12d3e-1234-5678-9012-95de01ee639c-s1"</td>
        </tr>
        <tr>
            <td>vpc_id</td>
            <td>The VPC ID of the remote client.</td>
            <td>string</td>
            <td></td>
            <td>yes</td>
            <td>"vpc-1234abcd"</td>
        </tr>
        <tr>
            <td>client_subnets</td>
            <td>The list of subnets in the client VPC to connect to.</td>
            <td>list(string)</td>
            <td></td>
            <td>yes</td>
            <td>["subnet-111122223333aaaab"]</td>
        </tr>
        <tr>
            <td>security_groups</td>
            <td>The security groups to attach to the ENIs for the broker nodes. MSK Cluster must allow to access by this Security Group.</td>
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
            <td>Amazon Resource Name (ARN) of the Managed VPC connection.</td>
            <td>string</td>
            <td>"arn:aws:kafka:ap-northeast-2:123456789012:vpc-connection/my-vpc-connection/abc123def456ghi789"</td>
        </tr>
    </tbody>
</table>

# LICENSE

- This module is customized from [terraform-aws-msk-kafka-cluster](https://github.com/terraform-aws-modules/terraform-aws-msk-kafka-cluster), and follows the license policy of [terraform-aws-msk-kafka-cluster](https://github.com/terraform-aws-modules/terraform-aws-msk-kafka-cluster).
- See for Apache-2.0 [LICENSE](https://github.com/oniops/tfmodule-aws-msk/blob/main/LICENSE).