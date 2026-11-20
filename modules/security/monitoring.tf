# Enterprise Audit Diagnostic Logging for Azure Key Vault
resource "azurerm_monitor_diagnostic_setting" "kv_diags" {
  count = var.log_analytics_workspace_id != null ? 1 : 0

  name                       = "diag-${var.key_vault_name}"
  target_resource_id         = azurerm_key_vault.kv.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AuditEvent"
  }

  enabled_log {
    category = "AzurePolicyEvaluationDetails"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
