output "vnet_id" {
  description = "The ID of the provisioned Virtual Network."
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "The name of the provisioned Virtual Network."
  value       = azurerm_virtual_network.vnet.name
}

output "subnet_ids" {
  description = "Map of subnet names to their Azure resource IDs."
  value       = { for k, v in azurerm_subnet.subnets : k => v.id }
}

output "nsg_id" {
  description = "The ID of the Network Security Group."
  value       = azurerm_network_security_group.nsg.id
}

output "route_table_id" {
  description = "The ID of the Route Table."
  value       = azurerm_route_table.route_table.id
}
