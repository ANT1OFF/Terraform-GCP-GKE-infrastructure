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

variable "cluster_endpoint" {
}

variable "cluster_ca_certificate" {
}