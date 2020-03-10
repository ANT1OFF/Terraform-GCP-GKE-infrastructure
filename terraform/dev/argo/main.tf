terraform {
  required_version = ">= 0.12.20"
   backend "gcs" {
    bucket  = "b2020-tf-state-dev"  # TODO: make variable or similar?
    prefix  = "terraform/state/dev/argo"
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


resource "null_resource" "get-kubectl" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${var.cluster_name} --region ${var.region} --project ${var.project_id}"
  }
}

# TODO: remove this
# !!!! TODO keep this
resource "null_resource" "sleep" {
  provisioner "local-exec" {
    command = "sleep 5"
  }
  depends_on = [
    null_resource.get-kubectl
  ]
}

resource "kubernetes_namespace" "argo" {
  metadata {
    name = "argocd"
  }
  depends_on = [
    null_resource.sleep
  ]
}

resource "null_resource" "argo-workload" {
  provisioner "local-exec" {
    command = "kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
  }
  depends_on = [
    kubernetes_namespace.argo, null_resource.get-kubectl
  ]
}

resource "kubernetes_namespace" "argo-rollout" {
  metadata {
    name = "argo-rollouts"
  }
  depends_on = [
    null_resource.argo-workload,
  ]
}

resource "null_resource" "argo-rollout-workload" {
  provisioner "local-exec" {
    command = "kubectl apply -n argo-rollouts -f https://raw.githubusercontent.com/argoproj/argo-rollouts/stable/manifests/install.yaml"
  }
  depends_on = [
    kubernetes_namespace.argo-rollout,
  ]
}

resource "null_resource" "argo-rollout-cluster-admin" {
  provisioner "local-exec" {
    command = "kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user ${data.terraform_remote_state.main.outputs.service_account_email}"
  }
  depends_on = [
    null_resource.argo-rollout-workload,
  ]
}

resource "kubernetes_service" "argocd-server-lb" {
  metadata {
    name = "terraform-argocd-server-lb"
    namespace = "argocd"
  }
  spec {
    selector = {
      "app.kubernetes.io/name" = "argocd-server"
    }
    session_affinity = "ClientIP"
    port {
      port = 443
    }
    type = "LoadBalancer"
  }
  depends_on = [
    null_resource.argo-rollout-workload,
  ]
}
