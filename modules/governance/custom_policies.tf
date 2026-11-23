# Custom Azure Policy Definition: Mandatory Enterprise Tags
resource "azurerm_policy_definition" "require_tags" {
  name         = "custom-enforce-mandatory-tags"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Enforce mandatory enterprise tags on all resources (Deny)"
  description  = "Denies creation of any resource lacking Environment, CostCenter, or ManagedBy tags."

  metadata = jsonencode({
    category = "Governance"
    version  = "1.0.0"
  })

  policy_rule = file("${path.module}/policies/require_tags.json")
}
