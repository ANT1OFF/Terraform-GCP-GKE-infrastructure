# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

project_id = "bachelor-2020"
credentials = "credentials.json" # path relative to *.tf files


# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES, MAY BE OMITTED
# ---------------------------------------------------------------------------------------------------------------------

# General
region = "europe-west1"

# VPC
domain            = "fonn.es"
network_name      = "vpc-network"
subnet_name       = "sub-02"
ip_range_sub      = "10.0.0.0/17"
ip_range_pods     = "192.168.0.0/18"
ip_range_services = "192.168.64.0/18"

# GKE
cluster_name = "tf-gke-cluster"
preemptible  = true
secrets = {
  secretkey = "secret value"
}

# Argocd
argocd_ingress = true
demo_app       = true

# Nginx 
cert_manager_install = true

# SQL
sql_database   = false
sql_autoresize = true
sql_version    = "POSTGRES_11"
# sql_availability = "REGIONAL"
sql_replica_count = 0
sql_backup_config = {
  binary_log_enabled = false # MySQL only
  enabled            = true
  start_time         = null
}