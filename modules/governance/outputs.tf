output "resource_group_ids" {
  description = "Map of resource group names to their resource IDs."
  value       = { for k, v in azurerm_resource_group.rgs : k => v.id }
}

output "policy_assignment_ids" {
  description = "Map of policy assignment names to their IDs."
  value       = { for k, v in azurerm_subscription_policy_assignment.policies : k => v.id }
}
