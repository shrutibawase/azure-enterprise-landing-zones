# Audited Enterprise Policy Exemptions
resource "azurerm_subscription_policy_exemption" "exemptions" {
  for_each = var.policy_exemptions

  name                 = each.key
  subscription_id      = var.subscription_id
  policy_assignment_id = each.value.policy_assignment_id
  exemption_category   = each.value.exemption_category
  expires_on           = each.value.expires_on
  description          = each.value.description
  display_name         = "Waiver: ${each.key}"
}
