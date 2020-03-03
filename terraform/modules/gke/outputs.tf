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
