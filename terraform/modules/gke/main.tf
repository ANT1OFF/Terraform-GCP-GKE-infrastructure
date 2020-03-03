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
  logging_service = "logging.googleapis.com/kubernetes"

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
      service_account    = var.service_account_email
    },
  ]
}


# ---------------------------------------------------------------------------------------------------------------------
# CREATE CLUSTER SECRETS
# ---------------------------------------------------------------------------------------------------------------------

locals {
  proxy_file_name = "proxyCreds.json"
  proxy_volume_and_secret_name ="cloudsql-instance-credentials"
}

resource "kubernetes_secret" "proxy-credentials" {
  metadata {
    name = local.proxy_volume_and_secret_name
  }

  data = {
    (local.proxy_file_name) = file(local.proxy_file_name)
  }
}


