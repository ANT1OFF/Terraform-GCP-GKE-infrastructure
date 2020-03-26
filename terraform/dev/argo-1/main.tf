terraform {
  required_version = ">= 0.12.20"
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

# ---------------------------------------------------------------------------------------------------------------------
# IAM CONFIGURATION
# ---------------------------------------------------------------------------------------------------------------------


module "service_accounts" {
  source        = "terraform-google-modules/service-accounts/google"
  project_id    = var.project_id
  prefix        = "tf"
  names         = ["gke-np-2-service-account"]
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY argocd and argo-rollouts
# ---------------------------------------------------------------------------------------------------------------------




data "terraform_remote_state" "main" {
  backend = "gcs"

  config = {
    bucket  = var.bucket_name
    prefix  = "terraform/state/cluster"
    credentials = var.credentials
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

resource "kubernetes_namespace" "argo" {
  metadata {
    name = var.argocd_namespace
  }
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
    command = "kubectl apply -n argo-rollouts -f https://raw.githubusercontent.com/argoproj/argo-rollouts/stable/manifests/install.yaml; kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user ${module.service_accounts.email}"
  }
  depends_on = [
    kubernetes_namespace.argo-rollout,
  ]
}



resource "kubernetes_service" "argocd-server-lb" {
  metadata {
    name = "terraform-argocd-server-lb"
    namespace = var.argocd_namespace
    annotations = {
    "kubernetes.io/ingress.class"                    = "nginx"
    "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
    "nginx.ingress.kubernetes.io/backend-protocol"   = "HTTP"
    }
  }
  spec {
    selector = {
      "app.kubernetes.io/name" = "argocd-server"
    }
    session_affinity = "ClientIP"
    port {
      port = 80
    }
    type = "LoadBalancer"
  }

  depends_on = [
    kubernetes_namespace.argo
  ]
}


resource "kubernetes_ingress" "nginx-ingress" {
  metadata {
    name = "argocd-server-ingress"
    namespace = var.argocd_namespace
    annotations = {
    "ingress.kubernetes.io/proxy-body-size" = "100M"
    "kubernetes.io/ingress.class"           = "nginx"
    "ingress.kubernetes.io/app-root"        = "/"
    }
  }
  spec {
    rule {
      host = "fonn.es"
      http {
        path {
          path = "/"
          backend {
            service_name = "argocd-server"
            service_port = "http"
          }
        }
      }
    }
    tls {
      hosts = ["argocd.fonn.es"]
      secret_name = "argocd-secret"
    }
  }
  depends_on = [
    kubernetes_namespace.argo
  ]
}
