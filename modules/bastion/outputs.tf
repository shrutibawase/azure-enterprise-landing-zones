output "bastion_id" {
  description = "Resource ID of the Azure Bastion Host."
  value       = azurerm_bastion_host.bastion.id
}

output "bastion_name" {
  description = "Name of the Azure Bastion Host."
  value       = azurerm_bastion_host.bastion.name
}

output "bastion_dns_name" {
  description = "The FQDN of the Azure Bastion Host."
  value       = azurerm_bastion_host.bastion.dns_name
}

output "bastion_public_ip" {
  description = "Public IP allocated to the Bastion host."
  value       = azurerm_public_ip.bastion_pip.ip_address
}
