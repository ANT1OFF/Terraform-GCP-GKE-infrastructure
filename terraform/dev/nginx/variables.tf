variable "project_id" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "credentials" {
  type = string
}

variable "region" {
  type = string
  default = "europe-west1"
}

variable "cluster_name" {
  type = string
}

variable "nginx_namespace" {
  type = string
  default = "nginx"
}

