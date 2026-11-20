# User-Assigned Managed Identities for Zero-Trust Services
resource "azurerm_user_assigned_identity" "identities" {
  for_each = var.identities

  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = merge(
    var.tags,
    each.value.tags,
    {
      "SecurityClassification" = "ManagedIdentity"
      "AuthMethod"             = "EntraID-Passwordless"
    }
  )
}
