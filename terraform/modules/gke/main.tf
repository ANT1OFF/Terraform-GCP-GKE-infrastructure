# ---------------------------------------------------------------------------------------------------------------------
# PREPARE PROVIDERS
# ---------------------------------------------------------------------------------------------------------------------

provider "google" {
  version = "~> 3.9.0"
  region  = var.region
  project = var.project_id
  credentials = var.credentials
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
  zones      = var.zone-for-cluster
  network    = var.vpc_network_name
  subnetwork = var.vpc_subnets_name
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  ip_range_pods              = "${var.subnet_name}-pods" #module.vpc.subnets_secondary_ranges[0][0].range_name
  ip_range_services          = "${var.subnet_name}-services" #module.vpc.subnets_secondary_ranges[0][1].range_name
  horizontal_pod_autoscaling = true

  #service_account = var.service_account_email
  service_account = "tf-bitbucket-02@bachelor-2020.iam.gserviceaccount.com"

  node_pools = [
    {
      name               = "default-node-pool"
      machine_type       = "n1-standard-1"  # TODO: make variable ?
      min_count          = 3
      max_count          = 100
      image_type         = "COS"
      auto_repair        = true
      auto_upgrade       = true
#      service_account    = var.service_account_email
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

///////////////////////////////////////////////////////////////////////////////////////
// Create the resources needed for the Stackdriver Export Sinks
///////////////////////////////////////////////////////////////////////////////////////

// Random string used to create a unique bucket name
resource "random_id" "server" {
  byte_length = 8
}

// Create a Cloud Storage Bucket for long-term storage of logs
// Note: the bucket has force_destroy turned on, so the data will be lost if you run
// terraform destroy
resource "google_storage_bucket" "gke-log-bucket" {
  name          = "stackdriver-gke-logging-bucket-${random_id.server.hex}"
  storage_class = "NEARLINE"
  force_destroy = true
}

// Create the Stackdriver Export Sink for Cloud Storage GKE Notifications
resource "google_logging_project_sink" "storage-sink" {
  name        = "gke-storage-sink"
  destination = "storage.googleapis.com/${google_storage_bucket.gke-log-bucket.name}"
  filter      = "resource.type = container"

  unique_writer_identity = true
}


// Grant the role of Storage Object Creator
resource "google_project_iam_binding" "log-writer-storage" {
  role = "roles/storage.objectCreator"

  members = [
    google_logging_project_sink.storage-sink.writer_identity,
  ]
}
