# terraform {
#   required_version = ">= 0.12.24"
#    backend "gcs" {
#     prefix  = "terraform/state/dev/nginx"
#   }
# }

# ---------------------------------------------------------------------------------------------------------------------
# Configure provider
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
# NGINX CONFIGURATION
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
  name      = "nginx"
  chart     = "stable/nginx-ingress"
  namespace = var.nginx_namespace

  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }
  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "controller.publishService.enabled"
    value = "true"
  }
  set {
    name  = "controller.service.loadBalancerIP"
    value = var.vpc_static_ip
  }

  depends_on = [kubernetes_namespace.nginx]
}


# ---------------------------------------------------------------------------------------------------------------------
# CERT-MANAGER CONFIGURATION
# ---------------------------------------------------------------------------------------------------------------------

resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}

# It ensures that a working local kubectl config is generated whenever terraform runs. needed for local-exec kubectl
resource "null_resource" "get-kubectl" {
  # To make it run every time:
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${var.cluster_name} --region ${var.region} --project ${var.project_id}"
  }
}

# TODO: add on destroy
resource "null_resource" "cert-manager-crd" {
  provisioner "local-exec" {
    command = "kubectl apply -n cert-manager -f https://github.com/jetstack/cert-manager/releases/download/v0.14.1/cert-manager.crds.yaml"
  }
  depends_on = [
    kubernetes_namespace.cert-manager, null_resource.get-kubectl
  ]
}

data "helm_repository" "jetstack" {
  name = "jetstack"
  url  = "https://charts.jetstack.io"
}


resource "helm_release" "cert-manager" {
  name      = "cert-manager"
  chart     = "jetstack/cert-manager"
  namespace = "cert-manager"
  version   = "0.14.1"

  depends_on = [null_resource.cert-manager-crd]
}

locals {
  issuer_file = "../modules/nginx/issuer.yaml"
}

# TODO: add on destroy
resource "null_resource" "cert-manager-issuer" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${local.issuer_file}"
  }

  depends_on = [
    kubernetes_namespace.cert-manager, null_resource.get-kubectl,
    helm_release.cert-manager
  ]
}