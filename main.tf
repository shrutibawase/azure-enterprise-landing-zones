module "governance" {
  source = "./modules/governance"

  subscription_id    = var.subscription_id
  resource_groups    = var.resource_groups
  global_tags        = var.global_tags
  policy_assignments = {
    "require-resource-tags" = {
      policy_definition_id   = "/providers/Microsoft.Authorization/policyDefinitions/1e30110a-5ceb-460c-a204-c14969fafe3d"
      display_name           = "Enforce mandatory Environment and CostCenter tags on all resources"
      non_compliance_message = "Deployment failed: Resource is missing required enterprise tags."
    }
  }
}

module "networking" {
  source = "./modules/networking"

  resource_group_name = var.resource_groups["rg-enterprise-network-${var.environment}"].location != "" ? "rg-enterprise-network-${var.environment}" : keys(var.resource_groups)[0]
  location            = var.primary_location
  vnet_name           = "vnet-hub-core-${var.environment}"
  vnet_address_space  = var.vnet_address_space
  subnets             = var.subnets
  nsg_rules           = var.nsg_rules
  custom_routes       = var.custom_routes
  tags                = var.global_tags

  depends_on = [module.governance]
}

module "firewall" {
  source = "./modules/firewall"

  resource_group_name = "rg-enterprise-network-${var.environment}"
  location            = var.primary_location
  firewall_name       = "afw-hub-${var.environment}"
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  subnet_id           = module.networking.subnet_ids["AzureFirewallSubnet"]
  tags                = var.global_tags

  depends_on = [module.governance, module.networking]
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

module "security" {
  source = "./modules/security"

  resource_group_name = "rg-enterprise-security-${var.environment}"
  location            = var.primary_location
  key_vault_name      = "kv-core-${var.environment}-${substr(sha256(var.subscription_id), 0, 6)}"
  tenant_id           = var.tenant_id
  sku_name            = "premium"

  network_acls = {
    bypass                     = "AzureServices"
    default_action             = "Deny"
    ip_rules                   = []
    virtual_network_subnet_ids = [module.networking.subnet_ids["AppSubnet"]]
  }

  private_endpoints = {
    "keyvault" = {
      subnet_id          = module.networking.subnet_ids["PrivateEndpointSubnet"]
      target_resource_id = "" # Bound to KV created inside child module
      subresource_names  = ["vault"]
    }
  }

  tags = var.global_tags

  depends_on = [module.governance, module.networking]
}

module "compute" {
  source = "./modules/compute"

  resource_group_name = "rg-enterprise-workloads-${var.environment}"
  location            = var.primary_location
  vmss_name           = "vmss-app-${var.environment}"
  sku                 = "Standard_D2s_v5"
  instances           = 2
  admin_username      = "azureadmin"
  ssh_public_key      = tls_private_key.ssh.public_key_openssh
  subnet_id           = module.networking.subnet_ids["AppSubnet"]

  custom_extensions = {
    "AzureMonitorLinuxAgent" = {
      publisher                  = "Microsoft.Azure.Monitor"
      type                       = "AzureMonitorLinuxAgent"
      type_handler_version       = "1.28"
      auto_upgrade_minor_version = true
    }
  }

  tags = var.global_tags

  depends_on = [module.governance, module.networking]
}
