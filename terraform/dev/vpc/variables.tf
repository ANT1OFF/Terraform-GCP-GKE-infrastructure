# ---------------------------------------------------------------------------------------------------------------------
# General vars
# ---------------------------------------------------------------------------------------------------------------------


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

# ---------------------------------------------------------------------------------------------------------------------
# VPC-vars
# ---------------------------------------------------------------------------------------------------------------------


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