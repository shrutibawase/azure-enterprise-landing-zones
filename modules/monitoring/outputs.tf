output "workspace_id" {
  description = "The Resource ID of the central Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.law.id
}

output "workspace_name" {
  description = "The Name of the central Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.law.name
}

output "primary_shared_key" {
  description = "The Primary Shared Key for the Log Analytics Workspace (sensitive)."
  value       = azurerm_log_analytics_workspace.law.primary_shared_key
  sensitive   = true
}

output "workspace_customer_id" {
  description = "The Workspace (Customer) ID for the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.law.workspace_id
}


output "app_insights_id" {
  description = "The Resource ID of the Application Insights component."
  value       = azurerm_application_insights.app_insights.id
}

output "app_insights_instrumentation_key" {
  description = "The Instrumentation Key for Application Insights (sensitive)."
  value       = azurerm_application_insights.app_insights.instrumentation_key
  sensitive   = true
}

output "app_insights_connection_string" {
  description = "The Connection String for Application Insights (sensitive)."
  value       = azurerm_application_insights.app_insights.connection_string
  sensitive   = true
}


output "data_collection_rule_id" {
  description = "The Resource ID of the Azure Monitor Data Collection Rule."
  value       = azurerm_monitor_data_collection_rule.dcr.id
}

output "data_collection_rule_immutable_id" {
  description = "The immutable ID of the Azure Monitor Data Collection Rule."
  value       = azurerm_monitor_data_collection_rule.dcr.immutable_id
}


output "alert_failed_requests_id" {
  description = "The Resource ID of the Application Insights failed requests metric alert."
  value       = azurerm_monitor_metric_alert.app_insights_failed_requests.id
}

output "alert_response_time_id" {
  description = "The Resource ID of the Application Insights response time metric alert."
  value       = azurerm_monitor_metric_alert.app_insights_response_time.id
}

output "alert_vmss_high_cpu_id" {
  description = "The Resource ID of the VMSS high CPU metric alert (if enabled)."
  value       = length(azurerm_monitor_metric_alert.vmss_high_cpu) > 0 ? azurerm_monitor_metric_alert.vmss_high_cpu[0].id : null
}
