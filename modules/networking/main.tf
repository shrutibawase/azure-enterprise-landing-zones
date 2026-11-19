resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.vnet_address_space
  dns_servers         = length(var.dns_servers) > 0 ? var.dns_servers : null

  dynamic "ddos_protection_plan" {
    for_each = var.enable_ddos_protection && var.ddos_protection_plan_id != null ? [1] : []
    content {
      id     = var.ddos_protection_plan_id
      enable = true
    }
  }

  tags = var.tags
}

resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                              = each.key
  resource_group_name               = var.resource_group_name
  virtual_network_name              = azurerm_virtual_network.vnet.name
  address_prefixes                  = each.value.address_prefixes
  service_endpoints                 = each.value.service_endpoints
  private_endpoint_network_policies = each.value.private_endpoint_network_policies

  dynamic "delegation" {
    for_each = coalesce(each.value.delegations, {})
    content {
      name = delegation.key
      service_delegation {
        name    = delegation.value.service_name
        actions = delegation.value.actions
      }
    }
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.vnet_name}-nsg"
  resource_group_name = var.resource_group_name
  location            = var.location

  dynamic "security_rule" {
    for_each = var.nsg_rules
    content {
      name                         = security_rule.key
      priority                     = security_rule.value.priority
      direction                    = security_rule.value.direction
      access                       = security_rule.value.access
      protocol                     = security_rule.value.protocol
      source_port_range            = security_rule.value.source_port_range
      source_port_ranges           = security_rule.value.source_port_ranges
      destination_port_range       = security_rule.value.destination_port_range
      destination_port_ranges      = security_rule.value.destination_port_ranges
      source_address_prefix        = security_rule.value.source_address_prefix
      source_address_prefixes      = security_rule.value.source_address_prefixes
      destination_address_prefix   = security_rule.value.destination_address_prefix
      destination_address_prefixes = security_rule.value.destination_address_prefixes
      description                  = security_rule.value.description
    }
  }

  tags = var.tags
}

resource "azurerm_route_table" "route_table" {
  name                          = "${var.vnet_name}-rt"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  bgp_route_propagation_enabled = true

  dynamic "route" {
    for_each = var.custom_routes
    content {
      name                   = route.key
      address_prefix         = route.value.address_prefix
      next_hop_type          = route.value.next_hop_type
      next_hop_in_ip_address = route.value.next_hop_in_ip_address
    }
  }

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  for_each = {
    for k, v in azurerm_subnet.subnets : k => v
    if k != "GatewaySubnet" && k != "AzureFirewallSubnet" && k != "AzureBastionSubnet"
  }

  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet_route_table_association" "rt_assoc" {
  for_each = {
    for k, v in azurerm_subnet.subnets : k => v
    if k != "GatewaySubnet" && k != "AzureFirewallSubnet"
  }

  subnet_id      = each.value.id
  route_table_id = azurerm_route_table.route_table.id
}
