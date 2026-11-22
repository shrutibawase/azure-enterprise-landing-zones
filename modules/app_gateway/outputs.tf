output "app_gateway_id" {
  description = "Resource ID of the Application Gateway."
  value       = azurerm_application_gateway.appgw.id
}

output "app_gateway_name" {
  description = "Name of the Application Gateway."
  value       = azurerm_application_gateway.appgw.name
}

output "public_ip_address" {
  description = "Public IP address of the Application Gateway."
  value       = azurerm_public_ip.appgw_pip.ip_address
}

output "backend_address_pool_id" {
  description = "Resource ID of the backend address pool (used by VMSS NIC configuration)."
  value       = tolist(azurerm_application_gateway.appgw.backend_address_pool)[0].id
}
