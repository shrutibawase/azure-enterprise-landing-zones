variable "subscription_id" {
  description = "Target Azure Subscription ID."
  type        = string
}

variable "tenant_id" {
  description = "Microsoft Entra ID Tenant ID."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, uat, prod)."
  type        = string
  default     = "prod"
}

variable "primary_location" {
  description = "Primary Azure region for Landing Zone."
  type        = string
  default     = "eastus2"
}

variable "resource_groups" {
  description = "Map of resource groups to provision across landing zones."
  type = map(object({
    location = string
    tags     = optional(map(string), {})
  }))
}

variable "vnet_address_space" {
  description = "CIDR block for the Hub Virtual Network."
  type        = list(string)
  default     = ["10.100.0.0/16"]
}

variable "subnets" {
  description = "Complex map of subnets with service endpoints, delegations, and NSG associations."
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
  description = "Map of Network Security Group rules executed dynamically."
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
}

variable "custom_routes" {
  description = "Map of custom UDRs forcing traffic through Azure Firewall."
  type = map(object({
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
}

variable "global_tags" {
  description = "Global enterprise metadata tags."
  type        = map(string)
  default = {
    "Organization" = "Enterprise-Platform-Engineering"
    "Architect"    = "Shruti Bawase"
    "Compliance"   = "CIS-Azure-Benchmark-v2.0"
  }
}
