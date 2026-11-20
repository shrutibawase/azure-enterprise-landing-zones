variable "resource_group_name" {
  description = "Target Resource Group name."
  type        = string
}

variable "location" {
  description = "Azure Region."
  type        = string
}

variable "key_vault_name" {
  description = "Name of the Azure Key Vault."
  type        = string
}

variable "tenant_id" {
  description = "Azure Active Directory / Entra ID tenant ID."
  type        = string
}

variable "sku_name" {
  description = "SKU for the Key Vault (standard or premium)."
  type        = string
  default     = "premium"
}

variable "network_acls" {
  description = "Network ACLs configuration for Key Vault."
  type = object({
    bypass                     = string
    default_action             = string
    ip_rules                   = list(string)
    virtual_network_subnet_ids = list(string)
  })
  default = {
    bypass                     = "AzureServices"
    default_action             = "Deny"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }
}

variable "private_endpoints" {
  description = "Map of private endpoints with sub-resources and private DNS zone associations."
  type = map(object({
    subnet_id            = string
    target_resource_id   = string
    subresource_names    = list(string)
    dns_zone_group_name  = optional(string, "default")
    private_dns_zone_ids = optional(list(string), [])
  }))
  default = {}
}

variable "tags" {
  description = "Enterprise tags."
  type        = map(string)
  default     = {}
}


variable "cmk_keys" {
  description = "Map of Customer-Managed Keys (CMK) to provision inside Key Vault."
  type = map(object({
    key_type = optional(string, "RSA")
    key_size = optional(number, 4096)
    key_opts = optional(list(string), [
      "decrypt",
      "encrypt",
      "sign",
      "unwrapKey",
      "verify",
      "wrapKey"
    ])
    tags = optional(map(string), {})
  }))
  default = {
    "cmk-storage-encryption" = {
      key_type = "RSA"
      key_size = 4096
      tags     = { "Usage" = "StorageDoubleEncryption" }
    }
    "cmk-disk-encryption" = {
      key_type = "RSA"
      key_size = 4096
      tags     = { "Usage" = "VMSSOSDiskEncryption" }
    }
  }
}
