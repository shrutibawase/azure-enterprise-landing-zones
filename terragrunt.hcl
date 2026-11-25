# ==============================================================================
# Root Terragrunt Configuration
# Provides DRY AzureRM provider generation and automated remote state management
# ==============================================================================

locals {
  # Automatically extract environment name from path (e.g. environments/prod -> prod)
  environment_path = basename(get_terragrunt_dir())
  environment      = local.environment_path == "" ? "prod" : local.environment_path
  subscription_id  = get_env("ARM_SUBSCRIPTION_ID", "00000000-0000-0000-0000-000000000000")
  tenant_id        = get_env("ARM_TENANT_ID", "11111111-1111-1111-1111-111111111111")
  primary_location = "eastus2"
}

# Generate AzureRM Provider dynamically
generate "provider" {
  path      = "provider_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">= 1.8.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.117"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = "${local.subscription_id}"
  tenant_id       = "${local.tenant_id}"
}
EOF
}

# Configure remote state storage in central Azure Storage Account
remote_state {
  backend = "azurerm"
  generate = {
    path      = "backend_override.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    resource_group_name  = "rg-enterprise-tfstate"
    storage_account_name = "stenterprisetfstate"
    container_name       = "tfstate"
    key                  = "${path_relative_to_include()}/terraform.tfstate"
  }
}
