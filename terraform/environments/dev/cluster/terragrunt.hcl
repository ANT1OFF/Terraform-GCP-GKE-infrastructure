# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../..//modules/gke/"
}

#Include all settings from the root terragrunt.hcl file

include {
  path = find_in_parent_folders()
}

locals {
  common_vars = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("common_vars.yaml")}"))
}

inputs = {
  subnet_name  = local.common_vars.subnet_name
  cluster_name = "tf-gke"

  vpc_network_name = dependency.vpc.outputs.network-name
  vpc_subnets_name = dependency.vpc.outputs.network-subnets
}

dependency "vpc" {
  config_path = "../vpc/"
}