resource "azurerm_resource_group" "rgs" {
  for_each = var.resource_groups

  name     = each.key
  location = each.value.location

  tags = merge(
    var.global_tags,
    each.value.tags,
    {
      "ManagedBy"   = "Terraform-Enterprise-Landing-Zone"
      "Provisioned" = timestamp()
    }
  )

  lifecycle {
    ignore_changes = [tags["Provisioned"]]
  }
}

resource "azurerm_subscription_policy_assignment" "policies" {
  for_each = var.policy_assignments

  name                 = each.key
  subscription_id      = var.subscription_id
  policy_definition_id = each.value.policy_definition_id
  display_name         = each.value.display_name
  parameters           = each.value.parameters

  dynamic "non_compliance_message" {
    for_each = each.value.non_compliance_message != null ? [each.value.non_compliance_message] : []
    content {
      content = non_compliance_message.value
    }
  }
}
