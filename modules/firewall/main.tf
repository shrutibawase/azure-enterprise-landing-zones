# Azure Firewall Public IP (Zone-Redundant, Standard SKU)
resource "azurerm_public_ip" "pip" {
  name                = "pip-${var.firewall_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]

  tags = var.tags
}

# Azure Firewall Policy
resource "azurerm_firewall_policy" "policy" {
  name                = "fwp-${var.firewall_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku_tier

  threat_intelligence_mode = "Alert"

  dns {
    proxy_enabled = true
  }

  tags = var.tags
}

# Rule Collection Group: Core Infrastructure & Egress Filtering
resource "azurerm_firewall_policy_rule_collection_group" "core_rules" {
  name               = "rcg-core-infrastructure"
  firewall_policy_id = azurerm_firewall_policy.policy.id
  priority           = 100

  # Application Rules: Authorized Outbound HTTPS/HTTP FQDNs
  application_rule_collection {
    name     = "app-whitelisted-egress"
    priority = 200
    action   = "Allow"

    rule {
      name = "allow-os-updates-and-cloud-apis"
      protocols {
        type = "Https"
        port = 443
      }
      protocols {
        type = "Http"
        port = 80
      }
      source_addresses = ["*"]
      destination_fqdns = [
        "*.azure.com",
        "*.microsoft.com",
        "*.github.com",
        "*.githubusercontent.com",
        "ghcr.io",
        "*.ubuntu.com",
        "archive.ubuntu.com",
        "security.ubuntu.com"
      ]
    }
  }

  # Network Rules: Core DNS and Time Sync
  network_rule_collection {
    name     = "net-core-infrastructure"
    priority = 300
    action   = "Allow"

    rule {
      name                  = "allow-dns-egress"
      protocols             = ["UDP", "TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["53"]
    }

    rule {
      name                  = "allow-ntp-time-sync"
      protocols             = ["UDP"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["123"]
    }
  }
}

# Azure Firewall Instance
resource "azurerm_firewall" "fw" {
  name                = var.firewall_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name
  sku_tier            = var.sku_tier
  firewall_policy_id  = azurerm_firewall_policy.policy.id
  zones               = ["1", "2", "3"]

  ip_configuration {
    name                 = "fw-ipconfig"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  tags = var.tags

  depends_on = [azurerm_firewall_policy_rule_collection_group.core_rules]
}
