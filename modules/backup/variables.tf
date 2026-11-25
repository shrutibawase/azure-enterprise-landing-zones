variable "resource_group_name" {
  description = "Name of the resource group hosting backup and recovery infrastructure."
  type        = string
}

variable "location" {
  description = "Azure region for the Recovery Services Vault."
  type        = string
}

variable "vault_name" {
  description = "Name of the Recovery Services Vault."
  type        = string
}

variable "sku" {
  description = "Vault SKU tier (Standard or RS0)."
  type        = string
  default     = "Standard"
}

variable "storage_mode_type" {
  description = "Storage replication mode (GeoRedundant, LocallyRedundant, ZoneRedundant)."
  type        = string
  default     = "GeoRedundant"
}

variable "cross_region_restore_enabled" {
  description = "Enables Cross Region Restore (CRR) to secondary paired region."
  type        = bool
  default     = true
}

variable "soft_delete_enabled" {
  description = "Enables immutable soft delete protection for backups against ransomware."
  type        = bool
  default     = true
}

variable "backup_policy_name" {
  description = "Name of the enterprise VM / VMSS backup policy."
  type        = string
  default     = "policy-daily-enterprise-backup"
}

variable "tags" {
  description = "Enterprise tags for backup resources."
  type        = map(string)
  default     = {}
}
