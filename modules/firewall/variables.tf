variable "resource_group_name" {
  description = "Resource group for the Azure Firewall."
  type        = string
}

variable "location" {
  description = "Azure region for the Azure Firewall."
  type        = string
}

variable "firewall_name" {
  description = "Name of the Azure Firewall."
  type        = string
}

variable "sku_name" {
  description = "SKU name of the Azure Firewall."
  type        = string
  default     = "AZFW_VNet"
}

variable "sku_tier" {
  description = "SKU tier of the Azure Firewall (Standard or Premium)."
  type        = string
  default     = "Standard"
}

variable "subnet_id" {
  description = "Resource ID of the dedicated AzureFirewallSubnet."
  type        = string
}

variable "tags" {
  description = "Enterprise tags for firewall resources."
  type        = map(string)
  default     = {}
}
