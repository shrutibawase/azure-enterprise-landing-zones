# CIS Microsoft Azure Foundations Benchmark v2.0 Initiative Assignment
resource "azurerm_subscription_policy_assignment" "cis_benchmark" {
  count = var.enable_cis_benchmark ? 1 : 0

  name                 = "cis-azure-foundations-v2"
  subscription_id      = var.subscription_id
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/0640751e-b507-4a6c-ac5e-e4793f18a5e7"
  display_name         = "CIS Microsoft Azure Foundations Benchmark v2.0.0"
  description          = "Automated compliance governance enforcing CIS Microsoft Azure Foundations Benchmark v2.0 controls."
  enforce              = true

  non_compliance_message {
    content = "Deployment violates CIS Microsoft Azure Foundations Benchmark v2.0 baseline."
  }
}
