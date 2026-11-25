subscription_id  = "00000000-0000-0000-0000-000000000001"
tenant_id        = "11111111-1111-1111-1111-111111111111"
environment      = "dev"
primary_location = "eastus2"

resource_groups = {
  "rg-enterprise-network-dev" = {
    location = "eastus2"
    tags     = { "Tier" = "Networking", "CostCenter" = "Dev-101", "Environment" = "dev" }
  }
  "rg-enterprise-security-dev" = {
    location = "eastus2"
    tags     = { "Tier" = "Security", "CostCenter" = "Dev-202", "Environment" = "dev" }
  }
  "rg-enterprise-workloads-dev" = {
    location = "eastus2"
    tags     = { "Tier" = "Compute", "CostCenter" = "Dev-303", "Environment" = "dev" }
  }
  "rg-enterprise-monitoring-dev" = {
    location = "eastus2"
    tags     = { "Tier" = "Monitoring", "CostCenter" = "Dev-404", "Environment" = "dev" }
  }
}

vnet_address_space = ["10.10.0.0/16"]

subnets = {
  "GatewaySubnet" = {
    address_prefixes = ["10.10.0.0/24"]
  }
  "AzureFirewallSubnet" = {
    address_prefixes = ["10.10.1.0/24"]
  }
  "AppSubnet" = {
    address_prefixes                  = ["10.10.10.0/24"]
    service_endpoints                 = ["Microsoft.KeyVault", "Microsoft.Storage"]
    private_endpoint_network_policies = "Enabled"
  }
  "PrivateEndpointSubnet" = {
    address_prefixes                  = ["10.10.20.0/24"]
    private_endpoint_network_policies = "Disabled"
  }
}

nsg_rules = {
  "allow-https-inbound" = {
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
    description                = "Allow internal HTTPS traffic from VNet"
  }
  "deny-all-inbound-default" = {
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "Strict Zero-Trust default deny rule"
  }
}

custom_routes = {
  "force-all-internet-to-firewall" = {
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.10.1.4"
  }
}

global_tags = {
  "Architect"       = "Shruti Bawase"
  "Framework"       = "Microsoft Cloud Adoption Framework"
  "Provisioner"     = "Terraform"
  "Environment"     = "Development"
  "ComplianceScope" = "Internal-Testing"
  "BusinessUnit"    = "Engineering"
}
