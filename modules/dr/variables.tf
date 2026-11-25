variable "primary_location" {
  description = "Primary active region for production workloads."
  type        = string
  default     = "eastus2"
}

variable "secondary_location" {
  description = "Paired secondary standby region for disaster recovery."
  type        = string
  default     = "centralus"
}

variable "rpo_minutes" {
  description = "Target Recovery Point Objective (RPO) in minutes."
  type        = number
  default     = 15
}

variable "rto_minutes" {
  description = "Target Recovery Time Objective (RTO) in minutes."
  type        = number
  default     = 60
}

variable "enable_automated_failover" {
  description = "Enables automated failover routing between primary and secondary paired regions."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Enterprise tags for disaster recovery resources."
  type        = map(string)
  default     = {}
}
