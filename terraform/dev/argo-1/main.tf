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
## IAM CONFIGURATION
## ---------------------------------------------------------------------------------------------------------------------
#
#
#module "service_accounts" {
#  source        = "terraform-google-modules/service-accounts/google"
#  project_id    = var.project_id
#  prefix        = "tf"
#  names         = ["gke-np-2-service-account"]
#}
#
## ---------------------------------------------------------------------------------------------------------------------
## DEPLOY argocd and argo-rollouts
## ---------------------------------------------------------------------------------------------------------------------
#
#
#
#
data "terraform_remote_state" "main" {
  backend = "gcs"

  config = {
    bucket  = var.bucket_name
    prefix  = "terraform/state/cluster"
    credentials = var.credentials
  }
}
#
#
#TODO: remove
resource "null_resource" "get-kubectl" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${var.cluster_name} --region ${var.region} --project ${var.project_id}"
  }
}
#
#resource "kubernetes_namespace" "argo" {
#  metadata {
#    name = var.argocd_namespace
#  }
#}
#
#resource "null_resource" "argo-workload" {
#  provisioner "local-exec" {
#    command = "kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
#  }
#  depends_on = [
#    kubernetes_namespace.argo, null_resource.get-kubectl
#  ]
#}
#
#resource "kubernetes_namespace" "argo-rollout" {
#  metadata {
#    name = "argo-rollouts"
#  }
#  depends_on = [
#    null_resource.argo-workload,
#  ]
#}
#
#resource "null_resource" "argo-rollout-workload" {
#  provisioner "local-exec" {
#    command = "kubectl apply -n argo-rollouts -f https://raw.githubusercontent.com/argoproj/argo-rollouts/stable/manifests/install.yaml; kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user ${module.service_accounts.email}"
#  }
#  depends_on = [
#    kubernetes_namespace.argo-rollout,
#  ]
#}
