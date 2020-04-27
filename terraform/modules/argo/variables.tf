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
# ARGO vars
# ---------------------------------------------------------------------------------------------------------------------

variable "cluster_name" {
  type        = string
  description = "Name of the cluster"
}

variable "argocd_namespace" {
  type        = string
  default     = "argocd"
  description = "Namespace for ArgoCD"
}

# TODO: use or remove. Update description
# variable "argocd_repo" {
#   type        = string
#   description = "ArgoCD repo"
# }

variable "cluster_endpoint" {
}

variable "cluster_ca_certificate" {
}