resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = var.vmss_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  instances           = var.instances
  admin_username      = var.admin_username
  zones               = ["1", "2", "3"]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Premium_ZRS"
    caching              = "ReadWrite"
  }

  custom_data = var.custom_data != null ? var.custom_data : filebase64("${path.module}/cloud-init.yaml")

  network_interface {
    name    = "${var.vmss_name}-nic"
    primary = true

    ip_configuration {
      name                                         = "internal"
      primary                                      = true
      subnet_id                                    = var.subnet_id
      application_gateway_backend_address_pool_ids = var.app_gateway_backend_pool_ids
    }
  }

  dynamic "extension" {
    for_each = var.custom_extensions
    content {
      name                       = extension.key
      publisher                  = extension.value.publisher
      type                       = extension.value.type
      type_handler_version       = extension.value.type_handler_version
      auto_upgrade_minor_version = extension.value.auto_upgrade_minor_version
      settings                   = extension.value.settings
      protected_settings         = extension.value.protected_settings
    }
  }

  tags = var.tags
}
