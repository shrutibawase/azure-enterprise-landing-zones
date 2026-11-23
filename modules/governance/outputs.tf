output "resource_group_ids" {
  description = "Map of resource group names to their resource IDs."
  value       = { for k, v in azurerm_resource_group.rgs : k => v.id }
}

output "policy_assignment_ids" {
  description = "Map of policy assignment names to their IDs."
  value       = { for k, v in azurerm_subscription_policy_assignment.policies : k => v.id }
}


output "cis_benchmark_assignment_id" {
  description = "The Policy Assignment ID for the CIS Azure Foundations Benchmark v2.0."
  value       = var.enable_cis_benchmark ? azurerm_subscription_policy_assignment.cis_benchmark[0].id : null
}


output "custom_policy_require_tags_id" {
  description = "Resource ID of the custom mandatory tags policy definition."
  value       = azurerm_policy_definition.require_tags.id
}


output "custom_policy_allowed_locations_id" {
  description = "Resource ID of the custom allowed locations policy definition."
  value       = azurerm_policy_definition.allowed_locations.id
}
