# ---------------------------------------------------------------------------------------------------------------------
# CREATE CLUSTER NAMESPACE
# ---------------------------------------------------------------------------------------------------------------------

resource "kubernetes_namespace" "argo" {
  metadata {
    name = "argocd"
  }
}

resource "null_resource" "argo-workload" {
  provisioner "local-exec" {
    command = "kubectl -n argocd apply -f ./argo.yaml"
  }
  depends_on = [
    kubernetes_namespace.argo,
  ]
}
