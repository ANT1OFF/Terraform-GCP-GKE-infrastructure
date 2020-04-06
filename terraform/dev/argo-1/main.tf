terraform {
  required_version = ">= 0.12.24"
   backend "gcs" {
    prefix  = "terraform/state/dev/argo-1"
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

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
  }
}


resource "helm_release" "argo-cd" {
  name       = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "2.0.3"
  namespace  = var.argocd_namespace


  values = [
    "${file("values.yaml")}"
  ]

  #set_string {
  #  name = "configs.secret.argocdServerAdminPassword"
  #  value = "fonnes"
  #}

  depends_on = [kubernetes_namespace.argocd]
}

## ---------------------------------------------------------------------------------------------------------------------
## DEPLOY argocd and argo-rollouts
## ---------------------------------------------------------------------------------------------------------------------


data "terraform_remote_state" "main" {
  backend = "gcs"

  config = {
    bucket  = var.bucket_name
    prefix  = "terraform/state/cluster"
    credentials = var.credentials
  }
}

# Nice to have:
# It ensures that a working local kubectl config is generated whenever terraform runs.
resource "null_resource" "get-kubectl" {
  # To make it run every time:
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${var.cluster_name} --region ${var.region} --project ${var.project_id}"
  }
}
