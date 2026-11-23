# Azure Monitor Metric Alert Rules for Application Performance and Infrastructure Health

# Alert 1: Application Insights Failed Requests Spike
resource "azurerm_monitor_metric_alert" "app_insights_failed_requests" {
  name                = "alert-appi-failed-requests"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights.app_insights.id]
  description         = "Triggers when application request failures exceed threshold in a 5-minute rolling window."
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "microsoft.insights/components"
    metric_name      = "requests/failed"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 10
  }

  action {
    action_group_id = azurerm_monitor_action_group.critical_incidents.id
  }

  tags = merge(
    var.tags,
    {
      "AlertCategory" = "ApplicationAvailability"
    }
  )
}

# Alert 2: Application Insights High Server Latency / Response Time
resource "azurerm_monitor_metric_alert" "app_insights_response_time" {
  name                = "alert-appi-high-response-time"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights.app_insights.id]
  description         = "Triggers when average HTTP response time exceeds 2000 milliseconds."
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "microsoft.insights/components"
    metric_name      = "requests/duration"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 2000
  }

  action {
    action_group_id = azurerm_monitor_action_group.critical_incidents.id
  }

  tags = merge(
    var.tags,
    {
      "AlertCategory" = "PerformanceDegradation"
    }
  )
}

# Alert 3: VMSS Host High CPU Utilization Alert (> 85%)
resource "azurerm_monitor_metric_alert" "vmss_high_cpu" {
  count               = var.target_vmss_id != null ? 1 : 0
  name                = "alert-vmss-high-cpu"
  resource_group_name = var.resource_group_name
  scopes              = [var.target_vmss_id]
  description         = "Triggers when VMSS average CPU percentage exceeds 85% for 5 consecutive minutes."
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachineScaleSets"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 85
  }

  action {
    action_group_id = azurerm_monitor_action_group.critical_incidents.id
  }

  tags = merge(
    var.tags,
    {
      "AlertCategory" = "InfrastructureCompute"
    }
  )
}
