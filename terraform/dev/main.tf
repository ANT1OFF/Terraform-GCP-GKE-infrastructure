terraform {
  required_version = ">= 0.12.20"
}


locals {
  cluster_type = "deploy-service"
}

# ---------------------------------------------------------------------------------------------------------------------
# PREPARE PROVIDERS
# ---------------------------------------------------------------------------------------------------------------------


provider "google" {
  version = "~> 3.9.0"
  region  = var.region
  project = var.project_id
  credentials = file("credentials.json")
}


provider "kubernetes" {
  load_config_file       = false
  host                   = "https://${module.kubernetes-engine.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.kubernetes-engine.ca_certificate)
}

data "google_client_config" "default" {
}


# ---------------------------------------------------------------------------------------------------------------------
# CREATE A NETWORK TO DEPLOY THE CLUSTER TO
# ---------------------------------------------------------------------------------------------------------------------
locals {
  subnet_name = "sub-02"
}

module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "2.1.1"

  project_id   = var.project_id
  network_name = var.network_name
  subnets = [
      {
          subnet_name           = local.subnet_name
          subnet_ip             = var.ip_range_sub
          subnet_region         = var.region
      },
  ]
  secondary_ranges = {
        sub-02 = [
            {
                range_name    = "${local.subnet_name}-secondary-01-pods"
                ip_cidr_range = var.ip_range_pods
            },
            {
                range_name    = "${local.subnet_name}-secondary-02-services"
                ip_cidr_range = var.ip_range_services
            },            
        ]
    }
}


module "service_accounts" {
  source        = "terraform-google-modules/service-accounts/google"
  project_id    = var.project_id
  prefix        = "tf"
  names         = ["gke-np-1-service-account"]
  project_roles = ["${var.project_id}=>roles/storage.objectViewer"]
}