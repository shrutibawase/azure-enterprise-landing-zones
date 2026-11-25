# Enterprise Virtual Machine & Workload Backup Policy
# Complies with ISO 27001 & CIS Azure Benchmark for Long-Term Data Retention

resource "azurerm_backup_policy_vm" "daily" {
  name                = var.backup_policy_name
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.rsv.name
  timezone            = "UTC"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 30
  }

  retention_weekly {
    count    = 12
    weekdays = ["Sunday"]
  }

  retention_monthly {
    count    = 12
    weekdays = ["Sunday"]
    weeks    = ["First"]
  }

  depends_on = [azurerm_recovery_services_vault.rsv]
}
