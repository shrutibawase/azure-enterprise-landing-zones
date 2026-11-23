# Azure Monitor Data Collection Rule (DCR) for Enterprise Telemetry
# Collects Linux Syslog, Security Events, and Operating System Performance Metrics

resource "azurerm_monitor_data_collection_rule" "dcr" {
  name                = "dcr-${var.workspace_name}-linux"
  resource_group_name = var.resource_group_name
  location            = var.location
  description         = "Data Collection Rule for Linux Syslog and VMSS host performance counters."

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.law.id
      name                  = "destination-log-analytics"
    }
  }

  data_flow {
    streams      = ["Microsoft-Syslog", "Microsoft-InsightsMetrics"]
    destinations = ["destination-log-analytics"]
  }

  data_sources {
    syslog {
      facility_names = ["auth", "authpriv", "cron", "daemon", "mark", "syslog"]
      log_levels     = ["Warning", "Error", "Critical", "Alert", "Emergency"]
      name           = "syslog-data-source"
      streams        = ["Microsoft-Syslog"]
    }

    performance_counter {
      streams                       = ["Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 60
      counter_specifiers = [
        "\\Processor Information(_Total)\\% Processor Time",
        "\\Memory\\% Available Memory",
        "\\LogicalDisk(_Total)\\% Free Space",
        "\\Network Interface(*)\\Bytes Total/sec"
      ]
      name = "perf-counter-data-source"
    }
  }

  tags = merge(
    var.tags,
    {
      "TelemetryType" = "DataCollectionRule"
    }
  )

  depends_on = [azurerm_log_analytics_workspace.law]
}
