output "vault_id" {
  description = "The Resource ID of the Recovery Services Vault."
  value       = azurerm_recovery_services_vault.rsv.id
}

output "vault_name" {
  description = "The Name of the Recovery Services Vault."
  value       = azurerm_recovery_services_vault.rsv.name
}

output "vault_identity_principal_id" {
  description = "System-assigned managed identity principal ID of the vault."
  value       = azurerm_recovery_services_vault.rsv.identity[0].principal_id
}

output "backup_policy_id" {
  description = "The Resource ID of the daily backup policy."
  value       = azurerm_backup_policy_vm.daily.id
}
