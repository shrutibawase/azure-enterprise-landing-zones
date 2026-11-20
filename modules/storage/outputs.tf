output "storage_account_id" {
  description = "The Resource ID of the provisioned Storage Account."
  value       = azurerm_storage_account.storage.id
}

output "storage_account_name" {
  description = "The Name of the provisioned Storage Account."
  value       = azurerm_storage_account.storage.name
}

output "primary_blob_endpoint" {
  description = "The endpoint URL for Blob Storage in the primary location."
  value       = azurerm_storage_account.storage.primary_blob_endpoint
}

output "primary_access_key" {
  description = "The primary access key for the storage account (sensitive)."
  value       = azurerm_storage_account.storage.primary_access_key
  sensitive   = true
}
