output "firewall_id" {
  description = "Resource ID of the Azure Firewall."
  value       = azurerm_firewall.fw.id
}

output "firewall_name" {
  description = "Name of the Azure Firewall."
  value       = azurerm_firewall.fw.name
}

output "firewall_private_ip" {
  description = "Private IP address of the Azure Firewall (used as next-hop for UDRs)."
  value       = azurerm_firewall.fw.ip_configuration[0].private_ip_address
}

output "firewall_public_ip" {
  description = "Public IP address of the Azure Firewall."
  value       = azurerm_public_ip.pip.ip_address
}

output "firewall_policy_id" {
  description = "Resource ID of the Azure Firewall Policy."
  value       = azurerm_firewall_policy.policy.id
}
