output "endpoint" {
  sensitive   = true
  description = "Cluster endpoint"
  value       = module.kubernetes-engine.endpoint
}

output "ca_certificate" {
  sensitive   = true
  description = "Cluster ca certificate (base64 encoded)"
  value       = module.kubernetes-engine.ca_certificate
}

output "cluster_name" {
  description = "Name of the cluster"
  value       = module.kubernetes-engine.name
}

output "app_prod_uid" {
  description = "UID of the Kubernetes namespace app-prod to create a dependency"
  value       = kubernetes_namespace.app-prod.metadata[0].name
}