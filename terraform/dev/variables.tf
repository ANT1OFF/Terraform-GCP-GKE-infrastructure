variable "project_id" {
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

variable "cluster_name_suffix" {
  type = string
  default = ""
}

variable "network_name" {
  type = string
  default = "vpc-network"
}

variable "subnet_name" {
  type = string
  default = "vpc-subnet"
}

variable "ip_range_sub" {
  type = string
  default = "10.42.0.0/20"
}

variable "ip_range_pods" {
  type = string
  default = "10.43.0.0/20"
}

variable "ip_range_services" {
  type = string
  default = "10.44.0.0/20"
}

variable "ingress" {
  type = bool
  default = false
}

variable "sql_database" {
  type = bool
  default = false
}

variable "sql_version" {
  type = string
}

variable "sql_tier" {
  type = string
  default = "db-f1-micro"
}

variable "psql_availability" {
  type = string
  default = "ZONAL"
}

variable "sql_autoresize" {
  type = bool
  default = true
}

variable "sql_disk_size" {
  type = number
  default = 10
}

variable "sql_disk_type" {
  type = string
  default = "PD_SSD"
}

variable "image_name" {
  type = string
  default = "nginx"
}

