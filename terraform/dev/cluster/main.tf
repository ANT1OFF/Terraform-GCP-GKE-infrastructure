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

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "kubernetes-engine" {
  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "7.2.0"
  
  project_id = var.project_id
  name       = var.cluster_name
  region     = var.region
  zones      = var.zone_for_cluster
  network    = data.terraform_remote_state.vpc.outputs.network-name
  subnetwork = data.terraform_remote_state.vpc.outputs.network-subnets
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  ip_range_pods              = "${data.terraform_remote_state.vpc.outputs.network-subnets}-pods"
  ip_range_services          = "${data.terraform_remote_state.vpc.outputs.network-subnets}-services"
  horizontal_pod_autoscaling = true

  create_service_account = true
  grant_registry_access = true

  node_pools = [
    {
      name               = "default-node-pool"
      machine_type       = "n1-standard-1"  # TODO: make variable ?
      min_count          = 3
      max_count          = 100
      image_type         = "COS"
      auto_repair        = true
      auto_upgrade       = true
      preemptible        = var.preemptible
    },
  ]
  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    default-node-pool = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}

data "google_client_config" "default" {
}

resource "google_project_service" "monitoring" {
  service            = "monitoring.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "container" {
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "logging" {
  service            = "logging.googleapis.com"
  disable_on_destroy = false
}

# ---------------------------------------------------------------------------------------------------------------------
# INSERTING ARBITRARY SECRETS INTO THE CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

provider "kubernetes" {
  load_config_file       = false
  host                   = "https://${module.kubernetes-engine.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.kubernetes-engine.ca_certificate)
}

# note: https://www.terraform.io/docs/state/sensitive-data.html
# Google Cloud buckets are encrypted by default
resource "kubernetes_secret" "secrets" {
  metadata {
    name = "arbitrary-secrets"
  }

  data = var.secrets
}
