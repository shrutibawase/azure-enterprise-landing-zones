# Dedicated Public IP for Azure Bastion
resource "azurerm_public_ip" "bastion_pip" {
  name                = "pip-${var.bastion_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

# Azure Bastion Host Instance
resource "azurerm_bastion_host" "bastion" {
  name                = var.bastion_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  scale_units         = var.scale_units
  copy_paste_enabled  = true
  file_copy_enabled   = var.sku == "Standard" ? var.file_copy_enabled : null
  tunneling_enabled   = var.sku == "Standard" ? var.tunneling_enabled : null

  ip_configuration {
    name                 = "bastion-ipconfig"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }

  tags = var.tags
}
