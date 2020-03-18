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
# SQL vars
# ---------------------------------------------------------------------------------------------------------------------

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
  description = "Name for the sql account for use by applications."
}

variable "sql_db_name" {
  type = string
  default = "default_db_name"
  description = "Name for the sql account for use by applications."
}

variable "sql_admin" {
  type = string
  default = "admin"
  description = "Name for the sql admin account."
}