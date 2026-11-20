# Customer-Managed Keys (CMK) Provisioned within Key Vault
resource "azurerm_key_vault_key" "cmk" {
  for_each = var.cmk_keys

  name         = each.key
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = each.value.key_type
  key_size     = each.value.key_size
  key_opts     = each.value.key_opts

  tags = merge(
    var.tags,
    each.value.tags,
    {
      "SecurityLevel" = "FIPS-140-2-Level-3"
      "KeyUsage"      = "CustomerManagedEncryption"
    }
  )

  depends_on = [azurerm_key_vault.kv]
}
