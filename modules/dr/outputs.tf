output "primary_region" {
  description = "The primary active region."
  value       = var.primary_location
}

output "secondary_region" {
  description = "The secondary standby disaster recovery paired region."
  value       = var.secondary_location
}

output "rpo_minutes" {
  description = "Target Recovery Point Objective (RPO)."
  value       = var.rpo_minutes
}

output "rto_minutes" {
  description = "Target Recovery Time Objective (RTO)."
  value       = var.rto_minutes
}

output "dr_status" {
  description = "DR configuration verification status."
  value       = terraform_data.dr_validation.output
}
