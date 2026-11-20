variable "resource_group_name" {
  description = "Name of the target resource group."
  type        = string
}

variable "location" {
  description = "Azure region where storage resources will be provisioned."
  type        = string
}

variable "storage_account_name" {
  description = "Name of the Storage Account (globally unique, lowercase alphanumeric)."
  type        = string
}

variable "account_tier" {
  description = "Defines the Tier to use for this storage account (Standard or Premium)."
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Type of replication: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  type        = string
  default     = "ZRS"
}

variable "user_assigned_identity_id" {
  description = "Resource ID of the User Assigned Identity used for CMK access."
  type        = string
  default     = null
}

variable "customer_managed_key_id" {
  description = "Key Vault Key Versionless ID used for Customer-Managed Key encryption."
  type        = string
  default     = null
}

variable "network_rules" {
  description = "Network rules governing access to the storage account."
  type = object({
    default_action             = string
    bypass                     = list(string)
    ip_rules                   = list(string)
    virtual_network_subnet_ids = list(string)
  })
  default = {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }
}

variable "tags" {
  description = "Enterprise tags for storage resources."
  type        = map(string)
  default     = {}
}
