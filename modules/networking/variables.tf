variable "resource_group_name" {
  description = "Name of the target resource group."
  type        = string
}

variable "location" {
  description = "Azure region where networking resources will be provisioned."
  type        = string
}

variable "vnet_name" {
  description = "Name of the Virtual Network."
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the Virtual Network in CIDR notation."
  type        = list(string)
}

variable "dns_servers" {
  description = "List of custom DNS servers to associate with the VNet."
  type        = list(string)
  default     = []
}

variable "enable_ddos_protection" {
  description = "Toggle for DDoS Protection Plan association."
  type        = bool
  default     = false
}

variable "ddos_protection_plan_id" {
  description = "Resource ID of an existing DDoS Protection Plan."
  type        = string
  default     = null
}

variable "subnets" {
  description = "Complex map of subnets with service endpoints, private endpoint policies, and delegation configurations."
  type = map(object({
    address_prefixes                  = list(string)
    service_endpoints                 = optional(list(string), [])
    private_endpoint_network_policies = optional(string, "Disabled")
    delegations = optional(map(object({
      service_name = string
      actions      = list(string)
    })), {})
  }))
}

variable "nsg_rules" {
  description = "Deep hierarchical map of Network Security Group rules executed via dynamic blocks."
  type = map(object({
    priority                     = number
    direction                    = string
    access                       = string
    protocol                     = string
    source_port_range            = optional(string)
    source_port_ranges           = optional(list(string))
    destination_port_range       = optional(string)
    destination_port_ranges      = optional(list(string))
    source_address_prefix        = optional(string)
    source_address_prefixes      = optional(list(string))
    destination_address_prefix   = optional(string)
    destination_address_prefixes = optional(list(string))
    description                  = optional(string)
  }))
  default = {}
}

variable "custom_routes" {
  description = "Map of user-defined routes (UDR) for forced tunneling and firewall inspection."
  type = map(object({
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  default = {}
}

variable "tags" {
  description = "Enterprise tags to apply to all networking resources."
  type        = map(string)
  default     = {}
}
