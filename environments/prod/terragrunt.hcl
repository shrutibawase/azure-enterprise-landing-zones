# Production Environment Terragrunt Orchestration
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_parent_terragrunt_dir()}/."
  
  extra_arguments "custom_vars" {
    commands = get_terraform_commands_that_need_vars()
    arguments = [
      "-var-file=terraform.tfvars"
    ]
  }
}
