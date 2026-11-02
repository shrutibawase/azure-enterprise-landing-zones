output "vmss_id" {
  description = "The ID of the Linux Virtual Machine Scale Set."
  value       = azurerm_linux_virtual_machine_scale_set.vmss.id
}

output "unique_id" {
  description = "The unique identifier of the VMSS."
  value       = azurerm_linux_virtual_machine_scale_set.vmss.unique_id
}
