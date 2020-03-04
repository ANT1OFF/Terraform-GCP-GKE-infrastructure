terraform {
  required_version = ">= 0.12.20"
   backend "gcs" {}
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
# CREATE THE CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "kubernetes-engine" {
  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "7.2.0"
  
  project_id = var.project_id
  name       = "${var.cluster_name}-cluster${var.cluster_name_suffix}"
  region     = var.region
  zones      = var.zone-for-cluster
  network    = var.vpc_network_name
  subnetwork = var.vpc_subnets_name
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  ip_range_pods              = "${var.subnet_name}-pods" #module.vpc.subnets_secondary_ranges[0][0].range_name
  ip_range_services          = "${var.subnet_name}-services" #module.vpc.subnets_secondary_ranges[0][1].range_name
  horizontal_pod_autoscaling = true

  node_pools = [
    {
      name               = "default-node-pool"
      machine_type       = "n1-standard-2"  # TODO: make variable ?
      min_count          = 3
      max_count          = 100
      image_type         = "COS"
      auto_repair        = true
      auto_upgrade       = true
      service_account    = module.service_accounts.email
    },
  ]
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
# CREATE CLUSTER SECRETS
# ---------------------------------------------------------------------------------------------------------------------

#locals {
#  proxy_file_name = "../../proxyCreds.json"
#  proxy_volume_and_secret_name ="cloudsql-instance-credentials"
#}
#
#resource "kubernetes_secret" "proxy-credentials" {
#  metadata {
#    name = local.proxy_volume_and_secret_name
#  }
#
#  data = {
#    (local.proxy_file_name) = file(local.proxy_file_name)
#  }
#}


