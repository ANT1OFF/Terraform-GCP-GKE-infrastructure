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
  default = "10.0.0.0/17"
}

variable "ip_range_pods" {
  type = string
  default = "192.168.0.0/18"
}

variable "ip_range_services" {
  type = string
  default = "192.168.64.0/18"
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

variable "sql_user" {
  type = string
  default = "appuser"
}

variable "sql_db_name" {
  type = string
  default = "default_db_name"
}

variable "image_name" {
  type = string
  default = "nginx"
}

variable "secrets" {
  type = list(object({
    name = string
    value = string
}))
  default = []
}