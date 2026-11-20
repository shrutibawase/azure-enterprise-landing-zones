# Private Endpoint for Azure Blob Storage
resource "azurerm_private_endpoint" "blob_pe" {
  count = var.private_endpoint != null && var.private_endpoint.enabled ? 1 : 0

  name                = "pe-${azurerm_storage_account.storage.name}-blob"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint.subnet_id

  private_service_connection {
    name                           = "psc-${azurerm_storage_account.storage.name}-blob"
    private_connection_resource_id = azurerm_storage_account.storage.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  dynamic "private_dns_zone_group" {
    for_each = length(var.private_endpoint.private_dns_zone_ids) > 0 ? [1] : []
    content {
      name                 = "privatelink-blob-dns-group"
      private_dns_zone_ids = var.private_endpoint.private_dns_zone_ids
    }
  }

  tags = var.tags
}
