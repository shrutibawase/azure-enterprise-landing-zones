variable "resource_group_name" {
  description = "Name of the resource group for Managed Identities."
  type        = string
}

variable "location" {
  description = "Azure region for Managed Identities."
  type        = string
}

variable "identities" {
  description = "Map of user-assigned managed identities to create."
  type = map(object({
    tags = optional(map(string), {})
  }))
  default = {
    "uami-workload-compute" = {
      tags = { "Role" = "WorkloadCompute", "Tier" = "Application" }
    }
    "uami-storage-encryption" = {
      tags = { "Role" = "StorageCMK", "Tier" = "Security" }
    }
    "uami-disk-encryption" = {
      tags = { "Role" = "DiskCMK", "Tier" = "Infrastructure" }
    }
  }
}

variable "tags" {
  description = "Enterprise tags for managed identities."
  type        = map(string)
  default     = {}
}
