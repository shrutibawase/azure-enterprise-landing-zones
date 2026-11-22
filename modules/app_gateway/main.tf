# Zone-Redundant Public IP for Application Gateway
resource "azurerm_public_ip" "appgw_pip" {
  name                = "pip-${var.app_gateway_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.zones

  tags = var.tags
}

locals {
  frontend_port_name             = "${var.app_gateway_name}-feport-80"
  frontend_ip_configuration_name = "${var.app_gateway_name}-feip"
  backend_address_pool_name      = "${var.app_gateway_name}-beap"
  backend_http_settings_name     = "${var.app_gateway_name}-be-htst"
  http_listener_name             = "${var.app_gateway_name}-httplstn"
  request_routing_rule_name      = "${var.app_gateway_name}-rqrt"
  probe_name                     = "${var.app_gateway_name}-hp"
}

# Application Gateway WAF_v2 with Zone Redundancy
resource "azurerm_application_gateway" "appgw" {
  name                = var.app_gateway_name
  resource_group_name = var.resource_group_name
  location            = var.location
  zones               = var.zones

  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  autoscale_configuration {
    min_capacity = var.min_capacity
    max_capacity = var.max_capacity
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.backend_http_settings_name
    cookie_based_affinity = "Disabled"
    port                  = var.backend_port
    protocol              = "Http"
    request_timeout       = 30
    probe_name            = local.probe_name
  }

  http_listener {
    name                           = local.http_listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 100
    rule_type                  = "Basic"
    http_listener_name         = local.http_listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.backend_http_settings_name
  }

  probe {
    name                                      = local.probe_name
    protocol                                  = "Http"
    path                                      = var.health_probe_path
    host                                      = "127.0.0.1"
    interval                                  = 15
    timeout                                   = 10
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = false

    match {
      status_code = ["200-399"]
    }
  }

  tags = var.tags
}
