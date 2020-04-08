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

variable "bucket_name" {
  type        = string
  description = "The globaly unique name for the GCP bucket containing the remote Terraform state"
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
  description = "Specifies whether a PostgreSQL instance should be set up for high availability (REGIONAL) or single zone (ZONAL)"
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
  description = "Name for the sql account for use by applications."
}

variable "sql_admin" {
  type        = string
  default     = "admin"
  description = "Name for the sql admin account."
}