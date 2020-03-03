terraform {
  required_version = ">= 0.12.20"
   backend "gcs" {
    bucket  = "b2020-tf-state-dev"  # TODO: make variable or similar?
    prefix  = "terraform/state"
    credentials = "credentials.json"
  }
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

#data "google_client_config" "default" {
#}

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
          subnet_private_access = "true"
      },
  ]
  secondary_ranges = {
        sub-02 = [
            {
                range_name    = "${local.subnet_name}-pods"
                ip_cidr_range = var.ip_range_pods
            },
            {
                range_name    = "${local.subnet_name}-services"
                ip_cidr_range = var.ip_range_services
            },            
        ]
    }
}


# ---------------------------------------------------------------------------------------------------------------------
# IAM CONFIGURATION
# ---------------------------------------------------------------------------------------------------------------------


module "service_accounts" {
  source        = "terraform-google-modules/service-accounts/google"
  project_id    = var.project_id
  prefix        = "tf"
  names         = ["gke-np-2-service-account"]
  project_roles = ["${var.project_id}=>roles/storage.objectViewer"]
}

# ---------------------------------------------------------------------------------------------------------------------
# GKE CONFIGURATION
# ---------------------------------------------------------------------------------------------------------------------

# Reference outputs from this data source to make a (cluster) module depend on
# "module.gcp-network" without "depends_on"
data "google_compute_subnetwork" "subnet" {
  name = reverse(split("/", module.vpc.subnets_names[0]))[0]
}

module "gke" {
  source = "../modules/gke"
  project_id = var.project_id
  subnet_name = local.subnet_name
  cluster_name = var.cluster_name
  service_account_email = module.service_accounts.email
  region = var.region

  # This appears to be one of the only ways to ensure the cluster creation happens after network creaton
  # without a "depends_on" clause, which are not available for modules.
  vpc_network_name = reverse(split("/", data.google_compute_subnetwork.subnet.network))[0]
  vpc_subnets_name = module.vpc.subnets_names[0]
}

