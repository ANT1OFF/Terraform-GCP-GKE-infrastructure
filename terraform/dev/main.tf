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

data "terraform_remote_state" "vpc" {
  backend = "gcs"

  config = {
    bucket  = "b2020-tf-state-dev"
    prefix  = "terraform/state/dev/vpc"
    credentials = "credentials.json"
  }
}

module "gke" {
  source = "../modules/gke"
  project_id = var.project_id
  subnet_name = data.terraform_remote_state.vpc.outputs.network-subnets
  cluster_name = var.cluster_name
  service_account_email = module.service_accounts.email
  region = var.region
  vpc_network_name = data.terraform_remote_state.vpc.outputs.network-name
  vpc_subnets_name = data.terraform_remote_state.vpc.outputs.network-subnets
}

