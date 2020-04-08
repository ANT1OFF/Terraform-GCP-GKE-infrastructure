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
# GKE-vars
# ---------------------------------------------------------------------------------------------------------------------

variable "zone_for_cluster" {
  type        = list(string)
  default     = ["europe-west1-b"]
  description = "The zones to host the cluster in (optional if regional cluster / required if zonal)"
}

variable "cluster_name" {
  type        = string
  default     = "tf-gke-cluster-default"
  description = "Name of the cluster"
}

variable "vpc_network_name" {
  type        = string
  description = "The VPC network to host the cluster in"
}

variable "vpc_subnets_name" {
  type        = string
  description = "The subnetwork to host the cluster in"
}

variable "preemptible" {
  type        = bool
  default     = false
  description = "A boolean that represents whether or not the underlying node VMs are preemptible"
}

# ---------------------------------------------------------------------------------------------------------------------
# Additional vars
# ---------------------------------------------------------------------------------------------------------------------

variable "secrets" {
  type = map(string)
  default = {}
  description = "Secrets referr to arbitrary secrets to be injected as Kubernetes secrets which, may be passed to an application as demonstrated with db-secrets in the example app deployment definition yaml"
}