# Workspace-Based Application Insights Component
resource "azurerm_application_insights" "app_insights" {
  name                = "appi-${var.workspace_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.law.id
  application_type    = "web"
  retention_in_days   = var.retention_in_days

  internet_ingestion_enabled = true
  internet_query_enabled     = true

  tags = merge(
    var.tags,
    {
      "TelemetryType" = "ApplicationPerformanceMonitoring"
    }
  )

  depends_on = [azurerm_log_analytics_workspace.law]
}
