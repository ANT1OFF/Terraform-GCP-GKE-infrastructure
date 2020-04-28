# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE PROVIDERS
# ---------------------------------------------------------------------------------------------------------------------
provider "google" {
  version     = "~> 3.9.0"
  region      = var.region
  project     = var.project_id
  credentials = file(var.credentials)
}

data "google_client_config" "default" {
  provider = google
}

provider "kubernetes" {
  load_config_file       = false
  host                   = "https://${var.cluster_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    load_config_file       = false
    host                   = "https://${var.cluster_endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ARGOCD HELM CONFIGURATION
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
  version    = "2.2.11"
  namespace  = var.argocd_namespace

  depends_on = [kubernetes_namespace.argocd]
}

# ---------------------------------------------------------------------------------------------------------------------
# ARGOCD-ROLLOUTS HELM CONFIGURATION
# ---------------------------------------------------------------------------------------------------------------------

resource "helm_release" "argocd-rollouts"{
  name  = "argocd-rollouts"
  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-rollouts"
  version    = "0.3.0"
  namespace = var.argocd_namespace

  depends_on = [kubernetes_namespace.argocd]
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY ARGOCD INGRESS
# ---------------------------------------------------------------------------------------------------------------------

# TODO: fix this
#locals {
#  ingress_file = "../modules/argo/argocd-ingress.yaml"
#}
#
## Insures that a working local kubectl config is generated whenever terraform runs.
#resource "null_resource" "get-kubectl" {
#  # To make it run every time:
#  triggers = {
#    always_run = "${timestamp()}"
#  }
#
#  provisioner "local-exec" {
#    command = "gcloud container clusters get-credentials ${var.cluster_name} --region ${var.region} --project ${var.project_id}"
#  }
#
#  depends_on = [helm_release.argo-cd]
#}
#
#resource "null_resource" "argocd-ingress" {
#  provisioner "local-exec" {
#    command = "kubectl apply -f ${local.ingress_file}"
#  }
#
#  depends_on = [null_resource.get-kubectl]
#}
