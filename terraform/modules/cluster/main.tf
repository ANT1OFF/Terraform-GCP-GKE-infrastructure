# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE PROVIDERS
# ---------------------------------------------------------------------------------------------------------------------


provider "google" {
  region      = var.region
  project     = var.project_id
  credentials = file(var.credentials)
}

provider "google-beta" {
  region      = var.region
  project     = var.project_id
  credentials = file(var.credentials)
}

# ---------------------------------------------------------------------------------------------------------------------
# Services and service account
# ---------------------------------------------------------------------------------------------------------------------

resource "google_service_account" "terraform" {
  account_id   = "terraform"
  display_name = "Terraform Service Account"
}

locals {
  terraform_sa = "serviceAccount:${google_service_account.terraform.email}"
}

resource "google_project_iam_member" "terraform" {
  for_each = toset(var.sa_roles)
  role     = each.key
  member   = local.terraform_sa
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

locals {
  istio_injection = var.istio ? "enabled" : "disabled"
  istio_auth      = var.istio ? "MTLS_PERMISSIVE" : "AUTH_MUTUAL_TLS"
}

module "kubernetes-engine" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster"
  version = "9.0.0"

  project_id         = var.project_id
  name               = var.cluster_name
  region             = var.region
  zones              = var.zone_for_cluster
  network            = var.network_name
  subnetwork         = var.network_subnets
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  ip_range_pods              = "${var.network_subnets}-pods"
  ip_range_services          = "${var.network_subnets}-services"
  horizontal_pod_autoscaling = true

  create_service_account = false
  service_account        = google_service_account.terraform.email
  grant_registry_access  = true

  istio = var.istio
  #istio_auth = local.istio_auth

  node_pools = [
    {
      name         = "default-node-pool"
      machine_type = var.machine_type
      min_count    = 3
      max_count    = 100
      image_type   = "COS"
      auto_repair  = true
      auto_upgrade = true
      preemptible  = var.preemptible
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

resource "kubernetes_namespace" "app-prod" {
  metadata {
    name = "prod"

    labels = {
      istio-injection = local.istio_injection
    }
  }
}

resource "kubernetes_namespace" "app-testing" {
  metadata {
    name = "test"
  }
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
