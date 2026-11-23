output "hub_vnet_id" {
  description = "The Resource ID of the Hub VNet."
  value       = module.networking.vnet_id
}

output "hub_subnets" {
  description = "Map of all provisioned subnets and their IDs."
  value       = module.networking.subnet_ids
}

output "key_vault_uri" {
  description = "The secure URI of the Enterprise Key Vault."
  value       = module.security.key_vault_uri
}

output "vmss_id" {
  description = "The Resource ID of the Virtual Machine Scale Set."
  value       = module.compute.vmss_id
}


output "firewall_private_ip" {
  description = "Private IP of the central Azure Firewall used as UDR next-hop."
  value       = module.firewall.firewall_private_ip
}

output "firewall_public_ip" {
  description = "Public IP of the central Azure Firewall."
  value       = module.firewall.firewall_public_ip
}


output "cis_benchmark_assignment_id" {
  description = "The Policy Assignment ID for the CIS Azure Foundations Benchmark v2.0."
  value       = module.governance.cis_benchmark_assignment_id
}

output "custom_policy_require_tags_id" {
  description = "Resource ID of the custom mandatory tags policy definition."
  value       = module.governance.custom_policy_require_tags_id
}

output "custom_policy_allowed_locations_id" {
  description = "Resource ID of the custom allowed locations policy definition."
  value       = module.governance.custom_policy_allowed_locations_id
}


output "log_analytics_workspace_id" {
  description = "The Resource ID of the central Log Analytics Workspace."
  value       = module.monitoring.workspace_id
}

output "application_insights_id" {
  description = "The Resource ID of the Application Insights component."
  value       = module.monitoring.app_insights_id
}

output "data_collection_rule_id" {
  description = "The Resource ID of the Azure Monitor Data Collection Rule for Linux telemetry."
  value       = module.monitoring.data_collection_rule_id
}

output "action_group_id" {
  description = "The Resource ID of the Azure Monitor Action Group for incident alerting."
  value       = module.monitoring.action_group_id
}
