terraform {
  required_version = ">= 0.12.20"
   backend "gcs" {
    prefix  = "terraform/state/dev/argo-2"
    credentials = "../credentials.json"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Configure provider
# ---------------------------------------------------------------------------------------------------------------------
provider "google" {
  version = "~> 3.9.0"
  region  = var.region
  project = var.project_id
  credentials = file("../credentials.json")
}

data "google_client_config" "default" {
  provider = google
}

provider "kubernetes" {
  version                = "~> 1.11.1"
  load_config_file       = false
  host                   = "https://${data.terraform_remote_state.main.outputs.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.terraform_remote_state.main.outputs.ca_certificate)
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY argocd and argo-rollouts
# ---------------------------------------------------------------------------------------------------------------------

data "terraform_remote_state" "main" {
  backend = "gcs"

  config = {
    bucket  = "b2020-tf-state-dev"
    prefix  = "terraform/state"
    credentials = "../credentials.json"
  }
}

# https://argoproj.github.io/argo-cd/operator-manual/declarative-setup/#repositories
# TODO: add credentials for private repos
resource "kubernetes_config_map" "argocd-config" {
  metadata {
    name = "argocd-cm"
    namespace = var.argocd_namespace
    labels = {
      "app.kubernetes.io/name" = "argocd-cm"
      "app.kubernetes.io/part-of" = "argocd"
    }
  }
  data = {
    repositories = <<EOF
- url: ${var.argocd_repo}
EOF
  }
}