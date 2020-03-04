terraform {
  required_version = ">= 0.12.20"
   backend "gcs" {}
}

# ---------------------------------------------------------------------------------------------------------------------
# GKE CONFIGURATION
# ---------------------------------------------------------------------------------------------------------------------

module "gke" {
  source = "../../modules//gke"
  subnet_name = local.subnet_name
  cluster_name = var.cluster_name
  service_account_email = module.service_accounts.email
  region = var.region
  vpc_network_name = module.vpc.network_name
  vpc_subnets_name = module.vpc.subnets_names[0]
}

