variable "project_id" {
  type = string
}

variable "region" {
  type = string
  default = "europe-west1"
}

variable "zone-for-cluster" {
  type = list(string)
  default = ["europe-west1-b"]
}

variable "cluster_name" {
  type = string
  default = "tf-gke-cluster-default"
}

variable "cluster_name_suffix" {
  type = string
  default = ""
}

variable "subnet_name" {
  type = string
}

variable "service_account_email" {
  type = string
}

variable "vpc_network_name" {
}

variable "vpc_subnets_name" {
}
