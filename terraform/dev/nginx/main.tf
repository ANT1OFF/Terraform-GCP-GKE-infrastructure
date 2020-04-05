terraform {
  required_version = ">= 0.12.24"
   backend "gcs" {
    prefix  = "terraform/state/dev/nginx"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Configure provider
# ---------------------------------------------------------------------------------------------------------------------
provider "google" {
  version = "~> 3.9.0"
  region  = var.region
  project = var.project_id
  credentials = file(var.credentials)
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

provider "helm" {
  kubernetes {
    load_config_file       = false
    host                   = "https://${data.terraform_remote_state.main.outputs.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(data.terraform_remote_state.main.outputs.ca_certificate)
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# HELM CONFIGURATION
# ---------------------------------------------------------------------------------------------------------------------

resource "kubernetes_namespace" "nginx" {
  metadata {
    name = var.nginx_namespace
  }
}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}


resource "helm_release" "ngninx" {
  name       = "nginx"
  chart      = "stable/nginx-ingress"
  namespace  = var.nginx_namespace

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "controller.publishService.enabled"
    value = "false"
  }


  depends_on = [kubernetes_namespace.nginx]
}

data "terraform_remote_state" "main" {
  backend = "gcs"

  config = {
    bucket  = var.bucket_name
    prefix  = "terraform/state/cluster"
    credentials = var.credentials
  }
}
