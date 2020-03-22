variable "project_id" {
  type = string
}

variable "region" {
  type = string
  default = "europe-west1"
}

variable "cluster_name" {
  type = string
}

variable "argocd_namespace" {
  type = string
  default = "argocd"
}

variable "argocd_repo" {
  type = string
}