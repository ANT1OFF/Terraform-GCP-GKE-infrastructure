# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../..//modules/vpc/"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

locals {
  common_vars = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("common_vars.yaml")}"))
}


inputs = {
  network_name      = "vpc-network"
  subnet_name       = local.common_vars.subnet_name
  ip_range_sub      = "10.0.0.0/17"
  ip_range_pods     = "192.168.0.0/18"
  ip_range_services = "192.168.64.0/18"
}
