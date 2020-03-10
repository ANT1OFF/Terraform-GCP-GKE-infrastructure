output "endpoint" {
    sensitive   = true
    description = "Cluster endpoint"
    value       = module.gke.endpoint
}

output "ca_certificate" {
    sensitive   = true
    description = "Cluster ca certificate (base64 encoded)"
    value       = module.gke.ca_certificate
}
