# Central Enterprise Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "law" {
  name                       = var.workspace_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  sku                        = "PerGB2018"
  retention_in_days          = var.retention_in_days
  daily_quota_gb             = var.daily_quota_gb
  internet_ingestion_enabled = true
  internet_query_enabled     = true

  tags = merge(
    var.tags,
    {
      "ServiceTier" = "CentralObservability"
      "Governance"  = "CIS-Azure-Monitor-v2.0"
    }
  )
}
