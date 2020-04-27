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
# Cluster-vars
# ---------------------------------------------------------------------------------------------------------------------

variable "cluster_name" {
  type        = string
  default     = "tf-gke-cluster-default"
  description = "Name of the cluster"
}

variable "zone_for_cluster" {
  type        = list(string)
  default     = ["europe-west1-b"]
  description = "The zones to host the cluster in (optional if regional cluster / required if zonal)"
}

variable "preemptible" {
  type        = bool
  default     = false
  description = "A boolean that represents whether or not the underlying node VMs are preemptible"
}

variable "secrets" {
  type        = map(string)
  default     = {}
  description = "Secrets referr to arbitrary secrets to be injected as Kubernetes secrets, which may be passed to an application as demonstrated with db-secrets in the example app deployment definition yaml"
}

variable "network_subnets" {
  description = "Subnets to use"
}

variable "network_name" {
  description = "Name of the VPC network"
}

variable "machine_type" {
  type        = string
  default     = "n1-standard-1"
  description = "The name of a Google Compute Engine machine type to use in the node pool"
}
