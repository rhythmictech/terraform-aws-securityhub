# General Security Hub Configuration
# ----------------------------------

variable "auto_enable_controls" {
  default     = true
  description = "Whether to automatically enable new controls when they are added to standards that are enabled"
  type        = bool
}

variable "control_finding_generator" {
  default     = "SECURITY_CONTROL"
  description = "Updates whether the calling account has consolidated control findings turned on"
  type        = string

  validation {
    condition     = contains(["SECURITY_CONTROL", "STANDARD_CONTROL"], var.control_finding_generator)
    error_message = "Allowed values for control_finding_generator are \"SECURITY_CONTROL\" or \"STANDARD_CONTROL\"."
  }
}

variable "enable_default_standards" {
  default     = true
  description = "Whether to enable the default standards provided by Security Hub"
  type        = bool
}

variable "product_subscriptions" {
  default = []
  type    = list(string)

  description = <<EOT
List of product subscriptions to enable in Security Hub. Format: 'vendor/product'.
Available AWS products include:
- aws/guardduty
- aws/inspector
- aws/access-analyzer
- aws/macie
- aws/detective
- aws/health
- aws/config
- aws/firewall-manager
- aws/systems-manager
- aws/iam-access-analyzer
- aws/chatbot
- aws/auditmanager
- aws/cloudhsm
- aws/cloudsearch
- aws/cloudtrail
- aws/codebuild
- aws/cognito-idp
- aws/connect
- aws/dms
- aws/dynamodb
- aws/ebs
- aws/ec2
- aws/ecr
- aws/ecs
- aws/efs
- aws/eks
- aws/elasticache
- aws/elasticbeanstalk
- aws/elb
- aws/es
- aws/fsx
- aws/kinesis
- aws/lambda
- aws/network-firewall
- aws/opensearch
- aws/rds
- aws/redshift
- aws/route53
- aws/s3
- aws/sagemaker
- aws/secretsmanager
- aws/ses
- aws/shield
- aws/sns
- aws/sqs
- aws/ssm
- aws/waf

For the most up-to-date and complete list, refer to AWS documentation:
https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-findings-providers.html
EOT
}

# Security Standards Configuration
# --------------------------------

variable "cis_standard_version" {
  default     = "3.0.0"
  description = "Version of the CIS AWS Foundations Benchmark to use"
  type        = string
}

variable "enable_aws_foundational_standard" {
  default     = true
  description = "Enable AWS Foundational Security Best Practices v1.0.0"
  type        = bool
}

variable "enable_cis_standard" {
  default     = true
  description = "Enable CIS AWS Foundations Benchmark"
  type        = bool
}

variable "enable_nist_standard" {
  default     = false
  description = "Enable NIST SP 800-53 Rev. 5 standard"
  type        = bool
}

variable "enable_pci_dss_standard" {
  default     = false
  description = "Enable PCI DSS v3.2.1"
  type        = bool
}

# Organization-level Configuration
# --------------------------------

variable "admin_account_id" {
  default     = null
  description = "AWS account ID for the Security Hub administrator account (required if enable_organization_config is true)"
  type        = string
}

variable "auto_enable_new_accounts" {
  default     = true
  description = "Automatically enable Security Hub for new accounts added to your organization (must be false when configuration_type_central is true)"
  type        = bool
}

variable "auto_enable_standards_for_new_accounts" {
  default     = true
  description = "Automatically enable Security Hub default standards for new accounts added to your organization (must be false when configuration_type_central is true). When true, sets auto_enable_standards to 'DEFAULT', otherwise 'NONE'."
  type        = bool
}

variable "central_configuration_policies" {
  default     = {}
  description = "Map of configuration policies to create in central configuration"
  type = map(object({
    description                  = string
    enabled                      = bool
    enabled_standard_arns        = list(string)
    enabled_control_identifiers  = optional(list(string))
    disabled_control_identifiers = optional(list(string))
    custom_parameters = optional(list(object({
      security_control_id = string
      parameter = object({
        name        = string
        value_type  = string
        bool        = optional(bool)
        double      = optional(number)
        enum        = optional(string)
        enum_list   = optional(list(string))
        int         = optional(number)
        int_list    = optional(list(number))
        string      = optional(string)
        string_list = optional(list(string))
      })
    })))
    targets = list(string)
  }))
}

variable "central_security_controls" {
  default     = {}
  description = "Map of security controls to enable/disable in central configuration"
  type = map(object({
    enabled         = bool
    disabled_reason = string
  }))
}

variable "configuration_type_central" {
  default     = false
  description = "Whether to use CENTRAL configuration type for organization configuration"
  type        = bool
}

variable "enable_organization_config" {
  default     = false
  description = "Whether to enable Security Hub configuration at the organization level"
  type        = bool
}

# Finding Aggregator Configuration
# --------------------------------

variable "enable_finding_aggregator" {
  default     = false
  description = "Whether to enable the Security Hub finding aggregator (must be true if enable_organization_config is true)"
  type        = bool
}

variable "finding_aggregator_linking_mode" {
  default     = "ALL_REGIONS"
  description = "Specifies the linking mode for the finding aggregator"
  type        = string

  validation {
    condition     = contains(["ALL_REGIONS", "SPECIFIED_REGIONS", "ALL_REGIONS_EXCEPT_SPECIFIED"], var.finding_aggregator_linking_mode)
    error_message = "Allowed values for finding_aggregator_linking_mode are \"ALL_REGIONS\" or \"ALL_REGIONS_EXCEPT_SPECIFIED\" or \"SPECIFIED_REGIONS\"."
  }
}

variable "finding_aggregator_regions" {
  default     = null
  description = "List of regions to aggregate findings from when linking_mode is SPECIFIED_REGIONS"
  type        = list(string)
}
