variable "project_id" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "credentials" {
  type = string
  default = "../credentials.json"
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