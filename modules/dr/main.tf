# Disaster Recovery & Cross-Region Business Continuity Architecture
# Manages Active-Passive Failover Controls and Region Pairing Metadata

locals {
  region_pairing_map = {
    "eastus2"   = "centralus"
    "centralus" = "eastus2"
  }

  is_valid_pairing = lookup(local.region_pairing_map, var.primary_location, "") == var.secondary_location
}

# Resource Group placeholder verification for DR
resource "terraform_data" "dr_validation" {
  input = {
    primary_region   = var.primary_location
    secondary_region = var.secondary_location
    valid_pairing    = local.is_valid_pairing
    target_rpo       = "${var.rpo_minutes} minutes"
    target_rto       = "${var.rto_minutes} minutes"
    auto_failover    = var.enable_automated_failover
  }

  lifecycle {
    postcondition {
      condition     = local.is_valid_pairing
      error_message = "Invalid Azure paired region configuration: ${var.primary_location} is not paired with ${var.secondary_location}."
    }
  }
}
