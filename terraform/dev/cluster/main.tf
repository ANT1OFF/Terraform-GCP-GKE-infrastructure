terraform {
  required_version = ">= 0.12.24"
   backend "gcs" {
    prefix  = "terraform/state/cluster"
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# PREPARE PROVIDERS
# ---------------------------------------------------------------------------------------------------------------------


provider "google" {
  version = "~> 3.9.0"
  region  = var.region
  project = var.project_id
  credentials = file(var.credentials)
}

# ---------------------------------------------------------------------------------------------------------------------
# GKE CONFIGURATION
# ---------------------------------------------------------------------------------------------------------------------

data "terraform_remote_state" "vpc" {
  backend = "gcs"

  config = {
    bucket  = var.bucket_name
    prefix  = "terraform/state/dev/vpc"
    credentials = var.credentials
  }
}

module "gke" {
  source = "../../modules/gke"
  project_id = var.project_id
  credentials = file(var.credentials)
  cluster_name = var.cluster_name
  region = var.region
  zone_for_cluster = var.zone_for_cluster
  vpc_network_name = data.terraform_remote_state.vpc.outputs.network-name
  vpc_subnets_name = data.terraform_remote_state.vpc.outputs.network-subnets
  preemptible = var.preemptible
  secrets = var.secrets
}

