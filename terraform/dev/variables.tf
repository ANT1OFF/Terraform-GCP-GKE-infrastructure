# TODO: there shouldn't be two defaults (both in root and each of the modules)
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
# VPC-vars
# ---------------------------------------------------------------------------------------------------------------------

variable "network_name" {
  type        = string
  default     = "vpc-network"
  description = "The name of the VPC being created"
}

variable "subnet_name" {
  type        = string
  default     = "vpc-subnet"
  description = "The name of the subnet being created"
}

variable "ip_range_sub" {
  type        = string
  default     = "10.0.0.0/17"
  description = "The IP and CIDR range of the subnet being created"
}

variable "ip_range_pods" {
  type        = string
  default     = "192.168.0.0/18"
  description = "IP range available for the pods"
}

variable "ip_range_services" {
  type        = string
  default     = "192.168.64.0/18"
  description = "IP range available for the services"
}

variable "domain" {
  type        = string
  default     = "example.com"
  description = "The domain for the project, for instance example.com"
}

variable "firewall_ingress_allow" {
  type        = list(object({
    protocol = string
    ports    = list(string)
  }))
  default     = [
    {
      protocol = "tcp"
      ports    = ["80", "443"]
    }
  ]
  description = "The list of ingress ALLOW rules specified by the firewall. Ports must be either an integer or a range." # see https://www.terraform.io/docs/providers/google/r/compute_firewall.html
}

variable "firewall_ingress_deny" {
  type        = list(object({
    protocol = string
    ports    = list(string)
  }))
  default     = []
  description = "The list of ingress DENY rules specified by the firewall. Ports must be either an integer or a range." # see https://www.terraform.io/docs/providers/google/r/compute_firewall.html
}

variable "firewall_egress_allow" {
  type        = list(object({
    protocol = string
    ports    = list(string)
  }))
  default     = []
  description = "The list of egress ALLOW rules specified by the firewall. Ports must be either an integer or a range." # see https://www.terraform.io/docs/providers/google/r/compute_firewall.html
}

variable "firewall_egress_deny" {
  type        = list(object({
    protocol = string
    ports    = list(string)
  }))
  default     = []
  description = "The list of egress DENY rules specified by the firewall. Ports must be either an integer or a range." # see https://www.terraform.io/docs/providers/google/r/compute_firewall.html
}

# ---------------------------------------------------------------------------------------------------------------------
# Cluster vars
# ---------------------------------------------------------------------------------------------------------------------

variable "cluster_name" {
  type        = string
  default     = "tf-gke-cluster-default"
  description = "Name of the cluster"
}

variable "zone_for_cluster" {
  type        = list(string)
  default     = ["europe-west1-b"]
  description = "The zones to host the cluster in (optional if regional cluster / required if zonal)"
}

variable "preemptible" {
  type        = bool
  default     = false
  description = "A boolean that represents whether or not the underlying node VMs are preemptible"
}

variable "secrets" {
  type        = map(string)
  default     = {}
  description = "Secrets referr to arbitrary secrets to be injected as Kubernetes secrets, which may be passed to an application as demonstrated with db-secrets in the example app deployment definition yaml"
}

# ---------------------------------------------------------------------------------------------------------------------
# SQL vars
# ---------------------------------------------------------------------------------------------------------------------

variable "sql_database" {
  type        = bool
  default     = false
  description = "Whether or not a database should be provisioned"
}

variable "sql_version" {
  type        = string
  default     = "POSTGRES_11"
  description = "The database version to run. See https://cloud.google.com/sql/docs/sqlserver/db-versions for available versions"
}

variable "sql_tier" {
  type        = string
  default     = "db-f1-micro"
  description = "The machine type to use"
}

variable "psql_availability" {
  type        = string
  default     = "ZONAL"
  description = "Specifies whether a PostgreSQL instance should be set up for high availability (REGIONAL) or single zone (ZONAL) https://cloud.google.com/sql/docs/mysql/high-availability#normal"
}

variable "sql_autoresize" {
  type        = bool
  default     = true
  description = "Configuration to increase storage size automatically"
}

variable "sql_disk_size" {
  type        = number
  default     = 10
  description = "The size of data disk, in GB. Size of a running instance cannot be reduced but can be increased"
}

variable "sql_disk_type" {
  type        = string
  default     = "PD_SSD"
  description = "The type of data disk: PD_SSD or PD_HDD"
}

variable "sql_user" {
  type        = string
  default     = "appuser"
  description = "Name for the sql account for use by applications."
}

variable "sql_db_name" {
  type        = string
  default     = "default_db_name"
  description = "Name for the sql database for use by applications."
}

variable "sql_admin" {
  type        = string
  default     = "admin"
  description = "Name for the sql admin account."
}

variable "sql_backup_config" {
  type = object({
    binary_log_enabled = bool
    enabled            = bool
    start_time         = string
  })
  default = {
    binary_log_enabled = null
    enabled            = false
    start_time         = null
  }
  description = "The backup_configuration settings subblock for the database setings. Binary log may only be enabled for MySQL instances."
}

variable "sql_replica_count" {
  type        = number
  default     = 0
  description = "Number of read replicas. Note, this requires the master to have binary_log_enabled set, as well as existing backups."
}
variable "sql_name" {
  type        = string
  default     = "terraform-db"
  description = "The name of the database"
}

# ---------------------------------------------------------------------------------------------------------------------
# ARGO vars
# ---------------------------------------------------------------------------------------------------------------------

variable "argocd_namespace" {
  type        = string
  default     = "argocd"
  description = "Namespace for ArgoCD"
}

# ---------------------------------------------------------------------------------------------------------------------
# NGINX vars
# ---------------------------------------------------------------------------------------------------------------------

variable "nginx_namespace" {
  type        = string
  default     = "nginx"
  description = "Namespace for the NGINX controller"
}