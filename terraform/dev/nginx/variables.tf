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

variable "bucket_name" {
  type        = string
  description = "The globaly unique name for the GCP bucket containing the remote Terraform state"
}

# ---------------------------------------------------------------------------------------------------------------------
# NGINX vars
# ---------------------------------------------------------------------------------------------------------------------

variable "cluster_name" {
  type        = string
  description = "Name of the cluster"
}

variable "nginx_namespace" {
  type        = string
  default     = "nginx"
  description = "Namespace for the NGINX controller"
}

