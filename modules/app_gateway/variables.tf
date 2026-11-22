variable "resource_group_name" {
  description = "Target Resource Group name."
  type        = string
}

variable "location" {
  description = "Azure Region for Application Gateway."
  type        = string
}

variable "app_gateway_name" {
  description = "Name of the Application Gateway."
  type        = string
}

variable "subnet_id" {
  description = "Resource ID of the dedicated Application Gateway subnet."
  type        = string
}

variable "zones" {
  description = "Availability Zones to deploy Application Gateway across."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "min_capacity" {
  description = "Minimum capacity units for autoscale (1-100)."
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum capacity units for autoscale (2-125)."
  type        = number
  default     = 10
}

variable "backend_port" {
  description = "Port on which the backend VMs listen."
  type        = number
  default     = 80
}

variable "health_probe_path" {
  description = "URL path for health probe validation."
  type        = string
  default     = "/healthz"
}

variable "tags" {
  description = "Enterprise tags."
  type        = map(string)
  default     = {}
}
