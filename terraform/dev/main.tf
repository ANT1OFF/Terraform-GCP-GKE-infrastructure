terraform {
  required_version = ">= 0.12.24"
   backend "gcs" {
    prefix  = "terraform2/state"
  }
}

# TODO: pass all variables to modules

module "vpc" {
  source            = "../modules/vpc"
  project_id        = var.project_id
  credentials       = var.credentials
  region            = var.region
  domain            = var.domain
  network_name      = var.network_name
  subnet_name       = var.subnet_name
  ip_range_sub      = var.ip_range_sub
  ip_range_pods     = var.ip_range_pods
  ip_range_services = var.ip_range_services
}

module "cluster" {
  source           = "../modules/cluster"
  project_id       = var.project_id
  credentials      = var.credentials
  region           = var.region
  cluster_name     = var.cluster_name
  zone_for_cluster = var.zone_for_cluster
  preemptible      = var.preemptible
  secrets          = var.secrets
  network_name     = module.vpc.network-name
  network_subnets  = module.vpc.network-subnets
}

module "sql" {
  source = "../modules/sql"
  project_id             = var.project_id
  credentials            = var.credentials
  region                 = var.region
  sql_database           = var.sql_database
  sql_autoresize         = var.sql_autoresize
  sql_version            = var.sql_version
  psql_availability      = var.psql_availability
  sql_replica_count      = var.sql_replica_count
  sql_backup_config      = var.sql_backup_config
  cluster_endpoint       = module.cluster.endpoint
  cluster_ca_certificate = module.cluster.ca_certificate
}

module "argo-1" {
  source                 = "../modules/argo-1"
  project_id             = var.project_id
  credentials            = var.credentials
  region                 = var.region
  cluster_name           = module.cluster.cluster_name
  cluster_endpoint       = module.cluster.endpoint
  cluster_ca_certificate = module.cluster.ca_certificate
}

module "nginx" {
  source                 = "../modules/nginx"
  project_id             = var.project_id
  credentials            = var.credentials
  region                 = var.region
  cluster_name           = module.cluster.cluster_name
  cluster_endpoint       = module.cluster.endpoint
  cluster_ca_certificate = module.cluster.ca_certificate
  vpc_static_ip          = module.vpc.static-ip
}