# ---------------------------------------------------------------------------------------------------------------------
# General vars
# ---------------------------------------------------------------------------------------------------------------------

variable "project_id" {
  type        = string
  description = "The project ID to host the cluster in"
}

variable "credentials" {
  type        = string
  description = "Credentials for the service account for Terraform to use when interacting with GCP"
}

variable "region" {
  type        = string
  default     = "europe-west1"
  description = "The region to host the cluster in (optional if zonal cluster / required if regional)"
}

# ---------------------------------------------------------------------------------------------------------------------
# VPC-vars
# ---------------------------------------------------------------------------------------------------------------------

variable "network_name" {
  type        = string
  default     = "vpc-network"
  description = "The name of the VPC being created"
}

variable "subnet_name" {
  type        = string
  default     = "vpc-subnet"
  description = "The name of the subnet being created"
}

variable "ip_range_sub" {
  type        = string
  default     = "10.0.0.0/17"
  description = "The IP and CIDR range of the subnet being created"
}

variable "ip_range_pods" {
  type        = string
  default     = "192.168.0.0/18"
  description = "IP range available for the pods"
}

variable "ip_range_services" {
  type        = string
  default     = "192.168.64.0/18"
  description = "IP range available for the services"
}

variable "domain" {
  type        = string
  default     = "example.com"
  description = "The domain for the project, for instance example.com"
}