# Central Azure Private DNS Zones
resource "azurerm_private_dns_zone" "zones" {
  for_each = toset(var.private_dns_zones)

  name                = each.value
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Cross-Product of Private DNS Zones and VNets for Dynamic Linking
locals {
  zone_vnet_pairs = flatten([
    for zone_name, zone in azurerm_private_dns_zone.zones : [
      for vnet_name, vnet in var.vnet_links : {
        key                  = "${zone_name}-${vnet_name}"
        zone_name            = zone.name
        vnet_name            = vnet_name
        vnet_id              = vnet.vnet_id
        registration_enabled = vnet.registration_enabled
      }
    ]
  ])
}

# Dynamic VNet Links
resource "azurerm_private_dns_zone_virtual_network_link" "links" {
  for_each = { for pair in local.zone_vnet_pairs : pair.key => pair }

  name                  = "link-${each.value.vnet_name}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = each.value.zone_name
  virtual_network_id    = each.value.vnet_id
  registration_enabled  = each.value.registration_enabled

  tags = var.tags
}
