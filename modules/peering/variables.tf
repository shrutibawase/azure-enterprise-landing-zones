variable "hub_resource_group_name" {
  description = "Resource group name of the Hub Virtual Network."
  type        = string
}

variable "hub_vnet_name" {
  description = "Name of the Hub Virtual Network."
  type        = string
}

variable "hub_vnet_id" {
  description = "Resource ID of the Hub Virtual Network."
  type        = string
}

variable "spoke_resource_group_name" {
  description = "Resource group name of the Spoke Virtual Network."
  type        = string
}

variable "spoke_vnet_name" {
  description = "Name of the Spoke Virtual Network."
  type        = string
}

variable "spoke_vnet_id" {
  description = "Resource ID of the Spoke Virtual Network."
  type        = string
}

variable "allow_gateway_transit" {
  description = "Controls if gateway transit is permitted from Hub to Spoke."
  type        = bool
  default     = true
}

variable "use_remote_gateways" {
  description = "Controls if Spoke uses remote gateways from Hub."
  type        = bool
  default     = false
}
