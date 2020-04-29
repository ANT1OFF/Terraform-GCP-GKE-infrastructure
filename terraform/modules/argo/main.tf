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
# TODO: add: change from default admin password(argocd-server podname) and store somwhere secure
resource "helm_release" "argo-cd" {
  name       = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "2.2.11"
  namespace  = var.argocd_namespace

  depends_on = [kubernetes_namespace.argocd]
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


resource "null_resource" "demo-application-argocd" {
  count = var.demo_app ? 1 : 0
  provisioner "local-exec" {
    command = "kubectl apply -f ../modules/argo/hipster.yaml"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -f ../modules/argo/hipster.yaml"
  }

  depends_on = [
    helm_release.argo-cd, 
    null_resource.get-kubectl
  ]
}


# ---------------------------------------------------------------------------------------------------------------------
# ARGOCD-ROLLOUTS HELM CONFIGURATION
# ---------------------------------------------------------------------------------------------------------------------

resource "helm_release" "argocd-rollouts"{
  name        = "argocd-rollouts"
  repository  = "https://argoproj.github.io/argo-helm"
  chart       = "argo-rollouts"
  version     = "0.3.0"
  namespace   = var.argocd_namespace

  depends_on = [kubernetes_namespace.argocd]
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY ARGOCD INGRESS
# ---------------------------------------------------------------------------------------------------------------------

# TODO: fix this https://argoproj.github.io/argo-cd/operator-manual/ingress/
resource "null_resource" "argocd-ingress" {
  count = var.argocd_ingress ? 1 : 0

  provisioner "local-exec" {
    command = "kubectl apply -f ../modules/argo/argocd-ingress.yaml"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -f ../modules/argo/argocd-ingress.yaml"
  }

  depends_on = [
    null_resource.get-kubectl, 
    kubernetes_namespace.argocd
    ]
}
