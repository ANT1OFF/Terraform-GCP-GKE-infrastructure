output "network-name" {
    description = "Name of network" # :-)
    value       = module.vpc.network_name
}

output "network-subnets" {
    description = "network-subnets"
    value       = module.vpc.subnets_names[0]
}

