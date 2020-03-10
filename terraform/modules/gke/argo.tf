# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY argocd and argo-rollouts
# ---------------------------------------------------------------------------------------------------------------------

resource "null_resource" "get-kubectl" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${module.kubernetes-engine.name} --region ${var.region} --project ${var.project_id}"
  }
  depends_on = [
    module.kubernetes-engine
  ]
}

# resource "null_resource" "sleep" {
#   provisioner "local-exec" {
#     command = "sleep 5"
#   }
#   depends_on = [
#     null_resource.get-kubectl
#   ]
# }

resource "kubernetes_namespace" "argo" {
  metadata {
    name = "argocd"
  }
  # depends_on = [
  #   null_resource.sleep
  # ]
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
    command = "kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user ${var.service_account_email}"
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
