variable "resource_group_name" {
  description = "Resource group for Azure Bastion."
  type        = string
}

variable "location" {
  description = "Azure region for Azure Bastion."
  type        = string
}

variable "bastion_name" {
  description = "Name of the Azure Bastion Host."
  type        = string
}

variable "sku" {
  description = "SKU of Azure Bastion (Basic or Standard)."
  type        = string
  default     = "Standard"
}

variable "scale_units" {
  description = "The number of scale units with which to provision Azure Bastion (2-50)."
  type        = number
  default     = 2
}

variable "subnet_id" {
  description = "Resource ID of the dedicated AzureBastionSubnet (minimum /26 CIDR)."
  type        = string
}

variable "tunneling_enabled" {
  description = "Enable native client tunneling support (SSH/RDP via az cli)."
  type        = bool
  default     = true
}

variable "file_copy_enabled" {
  description = "Enable file copy between browser and target VM."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Enterprise tags for Bastion resources."
  type        = map(string)
  default     = {}
}
