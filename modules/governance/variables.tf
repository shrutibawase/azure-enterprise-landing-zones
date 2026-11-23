variable "resource_groups" {
  description = "Map of resource groups to provision across environments with independent tagging."
  type = map(object({
    location = string
    tags     = optional(map(string), {})
  }))
}

variable "global_tags" {
  description = "Base enterprise tags to merge with resource-group specific tags."
  type        = map(string)
  default     = {}
}

variable "subscription_id" {
  description = "Target subscription ID for policy assignments."
  type        = string
}

variable "policy_assignments" {
  description = "Map of policy assignments to enforce compliance baselines."
  type = map(object({
    policy_definition_id   = string
    display_name           = string
    parameters             = optional(string)
    non_compliance_message = optional(string)
  }))
  default = {}
}


variable "enable_cis_benchmark" {
  description = "Enable CIS Microsoft Azure Foundations Benchmark v2.0 initiative assignment."
  type        = bool
  default     = true
}


variable "policy_exemptions" {
  description = "Map of policy exemptions for emergency or architectural waivers."
  type = map(object({
    policy_assignment_id = string
    exemption_category   = optional(string, "Mitigated")
    expires_on           = optional(string, null)
    description          = optional(string, "Approved architectural policy waiver.")
  }))
  default = {}
}
