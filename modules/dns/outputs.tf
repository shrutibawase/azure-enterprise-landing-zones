output "zone_ids" {
  description = "Map of private DNS zone names to their resource IDs."
  value       = { for k, v in azurerm_private_dns_zone.zones : k => v.id }
}

output "zone_names" {
  description = "List of managed private DNS zone names."
  value       = [for v in azurerm_private_dns_zone.zones : v.name]
}

output "vnet_link_ids" {
  description = "Map of VNet link keys to their resource IDs."
  value       = { for k, v in azurerm_private_dns_zone_virtual_network_link.links : k => v.id }
}
