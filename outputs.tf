output "hub_vnet_id" {
  description = "The Resource ID of the Hub VNet."
  value       = module.networking.vnet_id
}

output "hub_subnets" {
  description = "Map of all provisioned subnets and their IDs."
  value       = module.networking.subnet_ids
}

output "key_vault_uri" {
  description = "The secure URI of the Enterprise Key Vault."
  value       = module.security.key_vault_uri
}

output "vmss_id" {
  description = "The Resource ID of the Virtual Machine Scale Set."
  value       = module.compute.vmss_id
}
