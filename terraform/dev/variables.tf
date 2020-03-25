variable "project_id" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "region" {
  type = string
  default = "europe-west1"
}

variable "zone" {
  type = string
  default = "europe-west1-b"
}

variable "zone-for-cluster" {
  default = ["europe-west1-b"]
}

variable "cluster_name" {
  type = string
  default = "tf-gke-cluster-default"
}

variable "preemptible" {
  type = string
  default = false
}

variable "secrets" {
  type = map(string)
  default = {}
  description = "Secrets referr to arbitrary secrets to be injected as Kubernetes secrets, which may be passed to an application as demonstrated with db-secrets in the example app deployment definition yaml"
}