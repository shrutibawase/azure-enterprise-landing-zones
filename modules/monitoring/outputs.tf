output "workspace_id" {
  description = "The Resource ID of the central Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.law.id
}

output "workspace_name" {
  description = "The Name of the central Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.law.name
}

output "primary_shared_key" {
  description = "The Primary Shared Key for the Log Analytics Workspace (sensitive)."
  value       = azurerm_log_analytics_workspace.law.primary_shared_key
  sensitive   = true
}

output "workspace_customer_id" {
  description = "The Workspace (Customer) ID for the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.law.workspace_id
}
