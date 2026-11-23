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


# Custom Azure Policy Definition: Restrict Resource Locations
resource "azurerm_policy_definition" "allowed_locations" {
  name         = "custom-allowed-azure-locations"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Restrict resource deployment strictly to authorized Azure locations (Deny)"
  description  = "Enforces geo-fencing and data sovereignty by restricting resource deployments to eastus2 and centralus."

  metadata = jsonencode({
    category = "Governance"
    version  = "1.0.0"
  })

  policy_rule = file("${path.module}/policies/allowed_locations.json")
}
