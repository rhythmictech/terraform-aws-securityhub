data "aws_region" "current" {}

locals {
  region = data.aws_region.current.name

  product_arns = [for product in var.product_subscriptions :
    "arn:aws:securityhub:${local.region}::product/${product}"
  ]

  standards_arns = compact([
    var.enable_aws_foundational_standard ? "arn:aws:securityhub:${local.region}::standards/aws-foundational-security-best-practices/v/1.0.0" : null,
    var.enable_cis_standard ? "arn:aws:securityhub:${var.cis_standard_version == "1.2.0" || var.cis_standard_version == "1.4.0" ? "::ruleset" : "${local.region}::standards"}/cis-aws-foundations-benchmark/v/${var.cis_standard_version}" : null,
    var.enable_pci_dss_standard ? "arn:aws:securityhub:${local.region}::standards/pci-dss/v/3.2.1" : null,
    var.enable_nist_standard ? "arn:aws:securityhub:${local.region}::standards/nist-800-53/v/5.0.0" : null
  ])
}


resource "aws_securityhub_account" "this" {
  auto_enable_controls      = var.auto_enable_controls
  control_finding_generator = var.control_finding_generator
  enable_default_standards  = var.enable_default_standards
}

resource "time_sleep" "wait_securityhub_enable" {
  create_duration = "10s"

  depends_on = [aws_securityhub_account.this]
}

resource "aws_securityhub_finding_aggregator" "this" {
  count = var.enable_finding_aggregator ? 1 : 0

  linking_mode      = var.finding_aggregator_linking_mode
  specified_regions = var.finding_aggregator_linking_mode == "SPECIFIED_REGIONS" ? var.finding_aggregator_regions : null

  depends_on = [time_sleep.wait_securityhub_enable]
}

resource "aws_securityhub_standards_subscription" "standards" {
  for_each = toset(local.standards_arns)

  standards_arn = each.value
  depends_on    = [time_sleep.wait_securityhub_enable]
}

# Enable product integrations with Security Hub
resource "aws_securityhub_product_subscription" "subscriptions" {
  for_each = toset(local.product_arns)

  product_arn = each.value
  depends_on  = [time_sleep.wait_securityhub_enable]
}


resource "aws_securityhub_organization_admin_account" "org_admin" {
  count = var.admin_account_id != null ? 1 : 0

  admin_account_id = var.admin_account_id

  depends_on = [time_sleep.wait_securityhub_enable]
}

resource "aws_securityhub_organization_configuration" "org_config" {
  count = var.enable_organization_config ? 1 : 0

  auto_enable           = var.configuration_type_central ? false : var.auto_enable_new_accounts
  auto_enable_standards = var.configuration_type_central ? "NONE" : (var.auto_enable_standards_for_new_accounts ? "DEFAULT" : "NONE")

  organization_configuration {
    configuration_type = var.configuration_type_central ? "CENTRAL" : "LOCAL"
  }

  depends_on = [aws_securityhub_organization_admin_account.org_admin, aws_securityhub_finding_aggregator.this]
}

resource "aws_securityhub_standards_control" "central_controls" {
  for_each = var.configuration_type_central ? var.central_security_controls : {}

  standards_control_arn = each.key
  control_status        = each.value.enabled ? "ENABLED" : "DISABLED"
  disabled_reason       = each.value.enabled ? null : each.value.disabled_reason

  depends_on = [aws_securityhub_organization_configuration.org_config]
}

resource "aws_securityhub_configuration_policy" "central_policies" {
  for_each = var.configuration_type_central ? var.central_configuration_policies : {}

  name        = each.key
  description = each.value.description

  configuration_policy {
    service_enabled = each.value.enabled

    enabled_standard_arns = each.value.enabled_standard_arns

    security_controls_configuration {
      enabled_control_identifiers  = each.value.enabled_control_identifiers
      disabled_control_identifiers = each.value.disabled_control_identifiers

      dynamic "security_control_custom_parameter" {
        for_each = each.value.custom_parameters != null ? each.value.custom_parameters : []
        content {
          security_control_id = security_control_custom_parameter.value.security_control_id
          parameter {
            name       = security_control_custom_parameter.value.parameter.name
            value_type = security_control_custom_parameter.value.parameter.value_type
            dynamic "bool" {
              for_each = security_control_custom_parameter.value.parameter.bool != null ? [1] : []
              content {
                value = security_control_custom_parameter.value.parameter.bool
              }
            }
            dynamic "double" {
              for_each = security_control_custom_parameter.value.parameter.double != null ? [1] : []
              content {
                value = security_control_custom_parameter.value.parameter.double
              }
            }
            dynamic "enum" {
              for_each = security_control_custom_parameter.value.parameter.enum != null ? [1] : []
              content {
                value = security_control_custom_parameter.value.parameter.enum
              }
            }
            dynamic "enum_list" {
              for_each = security_control_custom_parameter.value.parameter.enum_list != null ? [1] : []
              content {
                value = security_control_custom_parameter.value.parameter.enum_list
              }
            }
            dynamic "int" {
              for_each = security_control_custom_parameter.value.parameter.int != null ? [1] : []
              content {
                value = security_control_custom_parameter.value.parameter.int
              }
            }
            dynamic "int_list" {
              for_each = security_control_custom_parameter.value.parameter.int_list != null ? [1] : []
              content {
                value = security_control_custom_parameter.value.parameter.int_list
              }
            }
            dynamic "string" {
              for_each = security_control_custom_parameter.value.parameter.string != null ? [1] : []
              content {
                value = security_control_custom_parameter.value.parameter.string
              }
            }
            dynamic "string_list" {
              for_each = security_control_custom_parameter.value.parameter.string_list != null ? [1] : []
              content {
                value = security_control_custom_parameter.value.parameter.string_list
              }
            }
          }
        }
      }
    }
  }

  depends_on = [aws_securityhub_organization_configuration.org_config]
}

resource "aws_securityhub_configuration_policy_association" "policy_associations" {
  for_each = var.configuration_type_central ? {
    for pair in flatten([
      for policy_name, policy in var.central_configuration_policies : [
        for target in policy.targets : {
          key         = "${policy_name}-${target}"
          policy_name = policy_name
          target      = target
        }
      ]
    ]) : pair.key => pair
  } : {}

  policy_id = aws_securityhub_configuration_policy.central_policies[each.value.policy_name].id
  target_id = each.value.target

  depends_on = [aws_securityhub_configuration_policy.central_policies]
}
