# Fine-Grained RBAC Role Assignments for Key Vault
resource "azurerm_role_assignment" "kv_roles" {
  for_each = var.role_assignments

  scope                = azurerm_key_vault.kv.id
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id

  depends_on = [azurerm_key_vault.kv]
}
