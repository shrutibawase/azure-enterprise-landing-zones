variable "resource_group_name" {
  description = "Resource group for central Private DNS Zones."
  type        = string
}

variable "private_dns_zones" {
  description = "List of Azure Private DNS zone names to manage (e.g. privatelink.vaultcore.azure.net)."
  type        = list(string)
  default = [
    "privatelink.vaultcore.azure.net",
    "privatelink.blob.core.windows.net",
    "privatelink.database.windows.net"
  ]
}

variable "vnet_links" {
  description = "Map of Virtual Networks to link to each Private DNS Zone."
  type = map(object({
    vnet_id              = string
    registration_enabled = optional(bool, false)
  }))
  default = {}
}

variable "tags" {
  description = "Enterprise tags for DNS resources."
  type        = map(string)
  default     = {}
}
