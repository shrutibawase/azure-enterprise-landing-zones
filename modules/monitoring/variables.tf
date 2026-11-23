variable "resource_group_name" {
  description = "Resource Group where monitoring resources will be deployed."
  type        = string
}

variable "location" {
  description = "Azure Region for monitoring resources."
  type        = string
}

variable "workspace_name" {
  description = "Name of the central Log Analytics Workspace."
  type        = string
}

variable "retention_in_days" {
  description = "Log retention period in days (minimum 30)."
  type        = number
  default     = 30
}

variable "daily_quota_gb" {
  description = "Maximum daily ingestion volume in GB to prevent runaway billing (-1 for unlimited)."
  type        = number
  default     = 10
}

variable "tags" {
  description = "Enterprise tags for monitoring resources."
  type        = map(string)
  default     = {}
}


variable "target_vmss_id" {
  description = "Optional Virtual Machine Scale Set Resource ID to attach CPU and memory metric alerts."
  type        = string
  default     = null
}


variable "notification_email" {
  description = "Default email address for enterprise security and operational alert notifications."
  type        = string
  default     = "secops@enterprise-domain.internal"
}

variable "webhook_service_uri" {
  description = "Optional HTTPS webhook URI for incident management integration (PagerDuty / ServiceNow / Teams)."
  type        = string
  default     = "https://events.pagerduty.com/integration/azure/alerts"
}
