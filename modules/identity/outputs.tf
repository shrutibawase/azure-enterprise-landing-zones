output "identity_ids" {
  description = "Map of managed identity names to their Azure Resource IDs."
  value       = { for k, v in azurerm_user_assigned_identity.identities : k => v.id }
}

output "principal_ids" {
  description = "Map of managed identity names to their Service Principal Object IDs (used for RBAC)."
  value       = { for k, v in azurerm_user_assigned_identity.identities : k => v.principal_id }
}

output "client_ids" {
  description = "Map of managed identity names to their Client (Application) IDs."
  value       = { for k, v in azurerm_user_assigned_identity.identities : k => v.client_id }
}
