terraform {
  required_version = ">= 0.12.20"
   backend "gcs" {
    prefix  = "terraform/state/dev/vpc"
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
# CREATE A NETWORK 
# ---------------------------------------------------------------------------------------------------------------------

module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 2.1.1"

  project_id   = var.project_id
  network_name = var.network_name
  subnets = [
      {
          subnet_name           = var.subnet_name
          subnet_ip             = var.ip_range_sub
          subnet_region         = var.region
          subnet_private_access = "true"
      },
  ]
  secondary_ranges = {
        sub-02 = [
            {
                range_name    = "${var.subnet_name}-pods"
                ip_cidr_range = var.ip_range_pods
            },
            {
                range_name    = "${var.subnet_name}-services"
                ip_cidr_range = var.ip_range_services
            },            
        ]
    }
}

