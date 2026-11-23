# Azure Monitor Action Group for Multi-Channel Incident Alerting
# Integrates Email, Webhook (PagerDuty / ServiceNow / Teams), and Azure RBAC Role Receivers

resource "azurerm_monitor_action_group" "critical_incidents" {
  name                = "ag-${var.workspace_name}-critical"
  resource_group_name = var.resource_group_name
  short_name          = "crit-alert"

  email_receiver {
    name                    = "secops-alert-email"
    email_address           = var.notification_email
    use_common_alert_schema = true
  }

  arm_role_receiver {
    name                    = "monitoring-contributors"
    role_id                 = "749f88d5-cbae-40b8-bcfc-f573eddca430" # Monitoring Contributor Built-in Role ID
    use_common_alert_schema = true
  }

  webhook_receiver {
    name                    = "incident-management-webhook"
    service_uri             = var.webhook_service_uri
    use_common_alert_schema = true
  }

  tags = merge(
    var.tags,
    {
      "AlertCategory" = "IncidentResponse"
    }
  )
}
