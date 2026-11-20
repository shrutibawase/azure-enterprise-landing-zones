output "key_vault_id" {
  description = "The ID of the Key Vault."
  value       = azurerm_key_vault.kv.id
}

output "key_vault_uri" {
  description = "The URI of the Key Vault."
  value       = azurerm_key_vault.kv.vault_uri
}

output "private_endpoint_ids" {
  description = "Map of private endpoint keys to their provisioned IDs."
  value       = { for k, v in azurerm_private_endpoint.endpoints : k => v.id }
}


output "cmk_key_ids" {
  description = "Map of CMK key names to their Key Vault Key versionless IDs."
  value       = { for k, v in azurerm_key_vault_key.cmk : k => v.versionless_id }
}

output "cmk_key_versions" {
  description = "Map of CMK key names to their active Key Vault Key versions."
  value       = { for k, v in azurerm_key_vault_key.cmk : k => v.version }
}
