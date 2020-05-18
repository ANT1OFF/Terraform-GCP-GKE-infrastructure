output "network-name" {
  description = "Name of the created VPC network"
  value       = module.vpc.network_name
}

output "network-subnets" {
  description = "Names of the created subnets"
  value       = module.vpc.subnets_names[0]
}

output "static-ip" {
  description = "Static IP allocated by the module"
  value       = google_compute_address.app-ip.address
}