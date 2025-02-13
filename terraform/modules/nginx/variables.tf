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

variable "vpc_static_ip" {
  description = "Static IP allocated by the VPC module"
}

variable "cluster_endpoint" {
  description = "Cluster endpoint"
}

variable "cluster_ca_certificate" {
  description = "Cluster ca certificate (base64 encoded)"
}

# ---------------------------------------------------------------------------------------------------------------------
# NGINX vars
# ---------------------------------------------------------------------------------------------------------------------

variable "cert_manager_install" {
  type    = bool
  default = true
  description = "Whether or not to install Cert-Manager"
}

variable "namespace_uid" {
  description = "UID of the Kubernetes namespace app-prod to create a dependency"
}