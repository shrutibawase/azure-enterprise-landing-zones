variable "resource_group_name" {
  description = "Target Resource Group name."
  type        = string
}

variable "location" {
  description = "Azure Region."
  type        = string
}

variable "vmss_name" {
  description = "Name of the Virtual Machine Scale Set."
  type        = string
}

variable "sku" {
  description = "Instance size SKU for VMSS."
  type        = string
  default     = "Standard_D2s_v5"
}

variable "instances" {
  description = "Number of initial VM instances."
  type        = number
  default     = 2
}

variable "admin_username" {
  description = "Administrator username for Linux VMs."
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key content."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where VMSS will be deployed."
  type        = string
}

variable "custom_extensions" {
  description = "Map of VM extensions executed dynamically (e.g. Azure Monitor Agent, Custom Script)."
  type = map(object({
    publisher                  = string
    type                       = string
    type_handler_version       = string
    auto_upgrade_minor_version = optional(bool, true)
    settings                   = optional(string)
    protected_settings         = optional(string)
  }))
  default = {}
}

variable "tags" {
  description = "Enterprise tags."
  type        = map(string)
  default     = {}
}


variable "app_gateway_backend_pool_ids" {
  description = "List of Application Gateway backend pool IDs to attach to the VMSS network interface."
  type        = list(string)
  default     = []
}


variable "custom_data" {
  description = "Base64-encoded cloud-init script for bootstrap execution."
  type        = string
  default     = null
}
