# terraform-aws-securityhub

This Terraform module configures AWS Security Hub for an AWS account or organization.


[![tflint](https://github.com/rhythmictech/terraform-aws-securityhub/workflows/tflint/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-securityhub/actions?query=workflow%3Atflint+event%3Apush+branch%3Amaster)
[![trivy](https://github.com/rhythmictech/terraform-aws-securityhub/workflows/trivy/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-securityhub/actions?query=workflow%3Atrivy+event%3Apush+branch%3Amaster)
[![yamllint](https://github.com/rhythmictech/terraform-aws-securityhub/workflows/yamllint/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-securityhub/actions?query=workflow%3Ayamllint+event%3Apush+branch%3Amaster)
[![misspell](https://github.com/rhythmictech/terraform-aws-securityhub/workflows/misspell/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-securityhub/actions?query=workflow%3Amisspell+event%3Apush+branch%3Amaster)
[![pre-commit-check](https://github.com/rhythmictech/terraform-aws-securityhub/workflows/pre-commit-check/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-securityhub/actions?query=workflow%3Apre-commit-check+event%3Apush+branch%3Amaster)
<a href="https://twitter.com/intent/follow?screen_name=RhythmicTech"><img src="https://img.shields.io/twitter/follow/RhythmicTech?style=social&logo=twitter" alt="follow on Twitter"></a>

## Features

- Enables AWS Security Hub
- Configures Security Hub settings
- Allows enabling/disabling of specific security standards
- Supports subscription to additional AWS product integrations
- Supports configuration at the organization level
- Supports central configuration policies

## Usage

## Example (Account Level)
```hcl
module "securityhub" {
  source                           = "rhythmictech/securityhub/aws"
  enable_default_standards         = true
  control_finding_generator        = "SECURITY_CONTROL"
  auto_enable_controls             = true
  enable_cis_standard              = true
  enable_pci_dss_standard          = true
  enable_aws_foundational_standard = true
  product_subscriptions = [
    "aws/guardduty",
    "aws/inspector",
    "aws/macie"
  ]
}
```

## Example (Organization Level)
```hcl
module "securityhub" {
source = "rhythmictech/securityhub/aws"
enable_organization_config = true
admin_account_id = "123456789012"
auto_enable_new_accounts = true
auto_enable_standards_for_new_accounts = true
enable_default_standards = true
control_finding_generator = "SECURITY_CONTROL"
auto_enable_controls = true
enable_cis_standard = true
enable_pci_dss_standard = true
enable_aws_foundational_standard = true
product_subscriptions = [
"aws/guardduty",
"aws/inspector",
"aws/macie"
]
}
```

## Example (Organization Level with CENTRAL configuration)
```hcl
module "securityhub" {
source = "rhythmictech/securityhub/aws"
enable_organization_config = true
admin_account_id = "123456789012"
configuration_type_central = true
enable_default_standards = true
control_finding_generator = "SECURITY_CONTROL"
auto_enable_controls = true
enable_cis_standard = true
enable_pci_dss_standard = true
enable_aws_foundational_standard = true
product_subscriptions = [
"aws/guardduty",
"aws/inspector",
"aws/macie"
]
configuration_type_central = true
}
```

## Example (Organization Level with LOCAL configuration)
```hcl
module "securityhub" {
source = "rhythmictech/securityhub/aws"
enable_organization_config = true
admin_account_id = "123456789012"
configuration_type_central = false
auto_enable_new_accounts = true
auto_enable_standards_for_new_accounts = true
enable_default_standards = true
control_finding_generator = "SECURITY_CONTROL"
auto_enable_controls = true
enable_cis_standard = true
enable_pci_dss_standard = true
enable_aws_foundational_standard = true
product_subscriptions = [
"aws/guardduty",
"aws/inspector",
"aws/macie"
]
}
```

## Example (Organization Level with CENTRAL configuration and control management)
```hcl
module "securityhub" {
source = "rhythmictech/securityhub/aws"
enable_organization_config = true
admin_account_id = "123456789012"
configuration_type_central = true
enable_default_standards = true
control_finding_generator = "SECURITY_CONTROL"
auto_enable_controls = true
enable_cis_standard = true
enable_pci_dss_standard = true
enable_aws_foundational_standard = true
product_subscriptions = [
"aws/guardduty",
"aws/inspector",
"aws/macie"
]
central_security_controls = {
"arn:aws:securityhub:us-east-1:123456789012:control/cis-aws-foundations-benchmark/v/1.2.0/1.1" = {
enabled = false
disabled_reason = "Not applicable to our environment"
},
"arn:aws:securityhub:us-east-1:123456789012:control/cis-aws-foundations-benchmark/v/1.2.0/1.2" = {
enabled = true
disabled_reason = null
}
}
}
```

## Example (Organization Level with CENTRAL configuration, control management, and configuration policies)
```hcl
module "securityhub" {
  source                           = "rhythmictech/securityhub/aws"
  enable_organization_config       = true
  admin_account_id                 = "123456789012"
  configuration_type_central       = true
  enable_default_standards         = true
  control_finding_generator        = "SECURITY_CONTROL"
  auto_enable_controls             = true
  enable_cis_standard              = true
  enable_pci_dss_standard          = true
  enable_aws_foundational_standard = true
  product_subscriptions            = [
    "aws/guardduty",
    "aws/inspector",
    "aws/macie"
  ]
  central_configuration_policies = {
    "Default Policy" = {
      description    = "Default configuration policy for all accounts"
      enabled        = true
      enabled_standard_arns = [
        "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0",
        "arn:aws:securityhub:${local.region}::standards/pci-dss/v/3.2.1"
      ]
      enabled_control_identifiers = [
        "CIS.1.1",
        "CIS.1.2"
      ]
      disabled_control_identifiers = [
        "PCI.DSS.v3.2.1/3.4"
      ]
      custom_parameters = [
        {
          security_control_id = "CIS.1.1"
          parameter = {
            name       = "MaxPasswordAge"
            value_type = "CUSTOM"
            value = {
              int = 60
            }
          }
        }
      ]
    }
  }
}

```

## Notes
- The `configuration_type_central` variable determines whether to use CENTRAL or LOCAL configuration type for organization configuration.
- When `configuration_type_central` is set to `true`, both `auto_enable_new_accounts` and `auto_enable_standards_for_new_accounts` must be set to `false`.
- The `central_configuration_policies` variable allows you to create and manage configuration policies when using CENTRAL configuration. Each policy can have its own settings for enabling standards, controls, and custom parameters.
- The `product_subscriptions` variable accepts a list of AWS products in the format 'vendor/product'. Refer to the variable description in `variables.tf` for a comprehensive list of available AWS products.
- A 10-second delay is added after enabling Security Hub to ensure proper setup before subscribing to standards and products.
- When configuring at the organization level, make sure you have the necessary permissions and that your AWS Organizations setup is complete.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.12 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.66.0 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.12.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_securityhub_account.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_account) | resource |
| [aws_securityhub_configuration_policy.central_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_configuration_policy) | resource |
| [aws_securityhub_configuration_policy_association.policy_associations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_configuration_policy_association) | resource |
| [aws_securityhub_finding_aggregator.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_finding_aggregator) | resource |
| [aws_securityhub_organization_admin_account.org_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_organization_admin_account) | resource |
| [aws_securityhub_organization_configuration.org_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_organization_configuration) | resource |
| [aws_securityhub_product_subscription.subscriptions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_product_subscription) | resource |
| [aws_securityhub_standards_control.central_controls](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_standards_control) | resource |
| [aws_securityhub_standards_subscription.standards](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_standards_subscription) | resource |
| [time_sleep.wait_securityhub_enable](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_account_id"></a> [admin\_account\_id](#input\_admin\_account\_id) | AWS account ID for the Security Hub administrator account (required if enable\_organization\_config is true) | `string` | `null` | no |
| <a name="input_auto_enable_controls"></a> [auto\_enable\_controls](#input\_auto\_enable\_controls) | Whether to automatically enable new controls when they are added to standards that are enabled | `bool` | `true` | no |
| <a name="input_auto_enable_new_accounts"></a> [auto\_enable\_new\_accounts](#input\_auto\_enable\_new\_accounts) | Automatically enable Security Hub for new accounts added to your organization (must be false when configuration\_type\_central is true) | `bool` | `true` | no |
| <a name="input_auto_enable_standards_for_new_accounts"></a> [auto\_enable\_standards\_for\_new\_accounts](#input\_auto\_enable\_standards\_for\_new\_accounts) | Automatically enable Security Hub default standards for new accounts added to your organization (must be false when configuration\_type\_central is true). When true, sets auto\_enable\_standards to 'DEFAULT', otherwise 'NONE'. | `bool` | `true` | no |
| <a name="input_central_configuration_policies"></a> [central\_configuration\_policies](#input\_central\_configuration\_policies) | Map of configuration policies to create in central configuration | <pre>map(object({<br>    description                  = string<br>    enabled                      = bool<br>    enabled_standard_arns        = list(string)<br>    enabled_control_identifiers  = optional(list(string))<br>    disabled_control_identifiers = optional(list(string))<br>    custom_parameters = optional(list(object({<br>      security_control_id = string<br>      parameter = object({<br>        name        = string<br>        value_type  = string<br>        bool        = optional(bool)<br>        double      = optional(number)<br>        enum        = optional(string)<br>        enum_list   = optional(list(string))<br>        int         = optional(number)<br>        int_list    = optional(list(number))<br>        string      = optional(string)<br>        string_list = optional(list(string))<br>      })<br>    })))<br>    targets = list(string)<br>  }))</pre> | `{}` | no |
| <a name="input_central_security_controls"></a> [central\_security\_controls](#input\_central\_security\_controls) | Map of security controls to enable/disable in central configuration | <pre>map(object({<br>    enabled         = bool<br>    disabled_reason = string<br>  }))</pre> | `{}` | no |
| <a name="input_cis_standard_version"></a> [cis\_standard\_version](#input\_cis\_standard\_version) | Version of the CIS AWS Foundations Benchmark to use | `string` | `"3.0.0"` | no |
| <a name="input_configuration_type_central"></a> [configuration\_type\_central](#input\_configuration\_type\_central) | Whether to use CENTRAL configuration type for organization configuration | `bool` | `false` | no |
| <a name="input_control_finding_generator"></a> [control\_finding\_generator](#input\_control\_finding\_generator) | Updates whether the calling account has consolidated control findings turned on | `string` | `"SECURITY_CONTROL"` | no |
| <a name="input_enable_aws_foundational_standard"></a> [enable\_aws\_foundational\_standard](#input\_enable\_aws\_foundational\_standard) | Enable AWS Foundational Security Best Practices v1.0.0 | `bool` | `true` | no |
| <a name="input_enable_cis_standard"></a> [enable\_cis\_standard](#input\_enable\_cis\_standard) | Enable CIS AWS Foundations Benchmark | `bool` | `true` | no |
| <a name="input_enable_default_standards"></a> [enable\_default\_standards](#input\_enable\_default\_standards) | Whether to enable the default standards provided by Security Hub | `bool` | `true` | no |
| <a name="input_enable_finding_aggregator"></a> [enable\_finding\_aggregator](#input\_enable\_finding\_aggregator) | Whether to enable the Security Hub finding aggregator (must be true if enable\_organization\_config is true) | `bool` | `false` | no |
| <a name="input_enable_nist_standard"></a> [enable\_nist\_standard](#input\_enable\_nist\_standard) | Enable NIST SP 800-53 Rev. 5 standard | `bool` | `false` | no |
| <a name="input_enable_organization_config"></a> [enable\_organization\_config](#input\_enable\_organization\_config) | Whether to enable Security Hub configuration at the organization level | `bool` | `false` | no |
| <a name="input_enable_pci_dss_standard"></a> [enable\_pci\_dss\_standard](#input\_enable\_pci\_dss\_standard) | Enable PCI DSS v3.2.1 | `bool` | `false` | no |
| <a name="input_finding_aggregator_linking_mode"></a> [finding\_aggregator\_linking\_mode](#input\_finding\_aggregator\_linking\_mode) | Specifies the linking mode for the finding aggregator | `string` | `"ALL_REGIONS"` | no |
| <a name="input_finding_aggregator_regions"></a> [finding\_aggregator\_regions](#input\_finding\_aggregator\_regions) | List of regions to aggregate findings from when linking\_mode is SPECIFIED\_REGIONS | `list(string)` | `null` | no |
| <a name="input_product_subscriptions"></a> [product\_subscriptions](#input\_product\_subscriptions) | List of product subscriptions to enable in Security Hub. Format: 'vendor/product'.<br>Available AWS products include:<br>- aws/guardduty<br>- aws/inspector<br>- aws/access-analyzer<br>- aws/macie<br>- aws/detective<br>- aws/health<br>- aws/config<br>- aws/firewall-manager<br>- aws/systems-manager<br>- aws/iam-access-analyzer<br>- aws/chatbot<br>- aws/auditmanager<br>- aws/cloudhsm<br>- aws/cloudsearch<br>- aws/cloudtrail<br>- aws/codebuild<br>- aws/cognito-idp<br>- aws/connect<br>- aws/dms<br>- aws/dynamodb<br>- aws/ebs<br>- aws/ec2<br>- aws/ecr<br>- aws/ecs<br>- aws/efs<br>- aws/eks<br>- aws/elasticache<br>- aws/elasticbeanstalk<br>- aws/elb<br>- aws/es<br>- aws/fsx<br>- aws/kinesis<br>- aws/lambda<br>- aws/network-firewall<br>- aws/opensearch<br>- aws/rds<br>- aws/redshift<br>- aws/route53<br>- aws/s3<br>- aws/sagemaker<br>- aws/secretsmanager<br>- aws/ses<br>- aws/shield<br>- aws/sns<br>- aws/sqs<br>- aws/ssm<br>- aws/waf<br><br>For the most up-to-date and complete list, refer to AWS documentation:<br>https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-findings-providers.html | `list(string)` | `[]` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
