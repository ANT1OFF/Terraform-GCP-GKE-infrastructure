# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY argocd and argo-rollouts
# ---------------------------------------------------------------------------------------------------------------------


resource "null_resource" "get-kubectl" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${module.kubernetes-engine.name} --region ${var.region} --project ${var.project_id}"
  }
}


resource "kubernetes_namespace" "argo" {
  metadata {
    name = "argocd"
  }
}

resource "null_resource" "argo-workload" {
  provisioner "local-exec" {
    command = "kubectl -n argocd apply -f ./manifests/argo.yaml"
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
    command = "kubectl -n argocd apply -f ./manifests/argo-rollout.yaml"
  }
  depends_on = [
    kubernetes_namespace.argo-rollout,
  ]
}