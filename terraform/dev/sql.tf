resource "google_sql_database_instance" "master" {
  count = var.sql_database ? 1 : 0
  
  database_version = var.sql_version
  region           = var.region

  settings {
    # Second-generation instance tiers are based on the machine type
    tier = var.sql_tier
    availability_type = var.psql_availability # REGIONAL/ZONAL
    disk_autoresize = var.sql_autoresize
    disk_size = var.sql_disk_size
    disk_type = var.sql_disk_type
  }
}

resource "google_sql_database" "mydb" {
  count = var.sql_database ? 1 : 0

  name     = var.sql_db_name
  instance = google_sql_database_instance.master[0].name
}

resource "google_sql_user" "users" {
  count = var.sql_database ? 1 : 0

  name     = var.sql_user
  instance = google_sql_database_instance.master[0].name
  password = random_password.db_password.result
}

resource "random_password" "db_password" {
  length = 16
}

# TODO: make like this https://github.com/GoogleCloudPlatform/cloudsql-proxy/blob/master/Kubernetes.md
provider "kubernetes" {
  load_config_file       = false
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}
data "google_client_config" "default" {
}

resource "kubernetes_secret" "database" {
  metadata {
    name = "db-secrets"
  }

  # TODO: make dynamic
  data = {
    DB_HOST = "localhost"
    DB_PORT = length(regexall(".*POSTGRES.*", var.sql_version)) > 0 ? 5432 : 3306 # TODO: fix
    DB_USER = var.sql_user
    DB_PASSWORD = random_password.db_password.result
    DB_NAME = var.sql_db_name
    DB_SSLMODE = "disable" # communication is encrypted by sql-proxy
  }
}
