# Enterprise TFLint Configuration - AzureRM & Terraform Rulesets
# Specification: https://github.com/terraform-linters/tflint

config {
  module = true
  force  = false
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "azurerm" {
  enabled = true
  version = "0.27.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

# Rule: Enforce standard naming conventions
rule "terraform_naming_convention" {
  enabled = true
}

# Rule: Catch unused variables and locals
rule "terraform_unused_declarations" {
  enabled = true
}

# Rule: Require explicit provider constraints
rule "terraform_required_providers" {
  enabled = true
}

# Rule: Require root terraform version constraint
rule "terraform_required_version" {
  enabled = true
}
