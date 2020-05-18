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

variable "cluster_endpoint" {
  description = "Cluster endpoint"
}

variable "cluster_ca_certificate" {
  description = "Cluster ca certificate (base64 encoded)"
}

variable "demo_app" {
  type        = bool
  default     = true
  description = "Whether or not to deploy the demo application"
}

variable "argocd_ingress" {
  type        = bool
  default     = true
  description = "If argocd shall be reachable from argocd.domain"
}

variable "namespace_uid" {
  description = "UID of the Kubernetes namespace app-prod to create a dependency"
}