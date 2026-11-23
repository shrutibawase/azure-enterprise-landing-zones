# Enterprise Hardened Azure Storage Account
resource "azurerm_storage_account" "storage" {
  name                              = var.storage_account_name
  resource_group_name               = var.resource_group_name
  location                          = var.location
  account_tier                      = var.account_tier
  account_replication_type          = var.account_replication_type
  account_kind                      = "StorageV2"
  https_traffic_only_enabled        = true
  min_tls_version                   = "TLS1_2"
  allow_nested_items_to_be_public   = false
  public_network_access_enabled     = false
  infrastructure_encryption_enabled = true

  dynamic "identity" {
    for_each = var.user_assigned_identity_id != null ? [1] : []
    content {
      type         = "UserAssigned"
      identity_ids = [var.user_assigned_identity_id]
    }
  }

  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key_id != null && var.user_assigned_identity_id != null ? [1] : []
    content {
      key_vault_key_id          = var.customer_managed_key_id
      user_assigned_identity_id = var.user_assigned_identity_id
    }
  }

  network_rules {
    default_action             = var.network_rules.default_action
    bypass                     = var.network_rules.bypass
    ip_rules                   = var.network_rules.ip_rules
    virtual_network_subnet_ids = var.network_rules.virtual_network_subnet_ids
  }

  blob_properties {
    versioning_enabled  = true
    change_feed_enabled = true

    delete_retention_policy {
      days = 30
    }

    container_delete_retention_policy {
      days = 30
    }
  }

  tags = merge(
    var.tags,
    {
      "SecurityCompliance" = "CIS-Azure-Storage-v2.0"
      "EncryptionAtRest"   = var.customer_managed_key_id != null ? "CustomerManagedKey-HSM" : "MicrosoftManaged"
      "DoubleEncryption"   = "Enabled"
    }
  )
}
