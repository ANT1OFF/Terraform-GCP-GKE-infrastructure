# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE PROVIDERS
# ---------------------------------------------------------------------------------------------------------------------

provider "google" {
  region      = var.region
  project     = var.project_id
  credentials = file(var.credentials)
}

provider "kubernetes" {
  load_config_file       = false
  host                   = "https://${var.cluster_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}

data "google_client_config" "default" {
}


# ---------------------------------------------------------------------------------------------------------------------
# CREATE DATABASE
# ---------------------------------------------------------------------------------------------------------------------

resource "google_sql_database_instance" "master" {
  count            = var.sql_database ? 1 : 0
  name             = "${var.sql_name}-master-${random_string.db-suffix.result}"
  database_version = var.sql_version
  region           = var.region

  settings {
    # Second-generation instance tiers are based on the machine type
    tier              = var.sql_tier
    availability_type = var.sql_availability # https://cloud.google.com/sql/docs/postgres/high-availability
    disk_autoresize   = var.sql_autoresize
    disk_size         = var.sql_disk_size
    disk_type         = var.sql_disk_type
    dynamic "backup_configuration" {
      for_each = [var.sql_backup_config]
      content {
        binary_log_enabled = lookup(backup_configuration.value, "binary_log_enabled", null)
        enabled            = lookup(backup_configuration.value, "enabled", null)
        start_time         = lookup(backup_configuration.value, "start_time", null)
      }
    }
  }
}

resource "google_sql_database_instance" "read-replicas" {
  count                = var.sql_database ? var.sql_replica_count : 0
  name                 = "${var.sql_name}-replica-${count.index}-${random_string.db-suffix.result}"
  database_version     = var.sql_version
  region               = var.region
  master_instance_name = google_sql_database_instance.master[0].name

  settings {
    tier            = var.sql_tier
    disk_autoresize = var.sql_autoresize
    disk_size       = var.sql_disk_size
    disk_type       = var.sql_disk_type
  }
}

resource "google_sql_database" "mydb" {
  count = var.sql_database ? 1 : 0

  name     = var.sql_db_name
  instance = google_sql_database_instance.master[0].name

  depends_on = [google_sql_database_instance.master]
}

resource "google_sql_user" "appuser" {
  count = var.sql_database ? 1 : 0

  name     = var.sql_user
  instance = google_sql_database_instance.master[0].name
  password = random_password.appuser.result

  depends_on = [google_sql_database_instance.master, random_password.appuser]
}

resource "google_sql_user" "admin" {
  count = var.sql_database ? 1 : 0

  name     = var.sql_admin
  instance = google_sql_database_instance.master[0].name
  password = random_password.admin.result

  depends_on = [google_sql_database_instance.master, random_password.admin]
}

resource "random_string" "db-suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "random_password" "appuser" {
  length = 24
}

resource "random_password" "admin" {
  length = 24
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE SQL PROXY
# ---------------------------------------------------------------------------------------------------------------------


# based on https://github.com/GoogleCloudPlatform/cloudsql-proxy/blob/master/Kubernetes.md
resource "kubernetes_deployment" "sql-proxy" {
  count = var.sql_database ? 1 : 0

  metadata {
    name = "terraform-sql-proxy"
    labels = {
      App = local.sql_proxy_label
    }
    namespace = "prod"
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = local.sql_proxy_label
      }
    }

    template {
      metadata {
        labels = {
          App = local.sql_proxy_label
        }
      }

      spec {
        container {
          # images: https://github.com/GoogleCloudPlatform/cloudsql-proxy/releases
          image = "gcr.io/cloudsql-docker/gce-proxy:1.16"
          name  = "sql-proxy"
          command = ["/cloud_sql_proxy",
            "-dir=/cloudsql",
            "-instances=${google_sql_database_instance.master[0].connection_name}=tcp:0.0.0.0:${local.db_port}", # additional databases may be included here
            "-credential_file=/secrets/cloudsql/${local.proxy_file_name}",
          "term_timeout=10s"]
          lifecycle {
            pre_stop {
              exec {
                command = ["sleep", "10"]
              }
            }
          }

          # in case of multiple databases, multiple ports need to be defined
          port {
            container_port = local.db_port
          }
          volume_mount {
            name       = local.proxy_volume_and_secret_name
            mount_path = "/secrets/cloudsql"
            read_only  = true
          }

          volume_mount {
            name       = "cloudsql"
            mount_path = "/cloudsql"
          }
        }

        volume {
          name = local.proxy_volume_and_secret_name
          secret {
            secret_name = local.proxy_volume_and_secret_name
          }
        }

        volume {
          name = "cloudsql"
          empty_dir {}
        }
      }
    }
  }

  depends_on = [kubernetes_secret.proxy-credentials]
}

resource "kubernetes_service" "sql-proxy" {
  count = var.sql_database ? 1 : 0


  metadata {
    name      = local.sql_proxy_name
    namespace = "prod"
  }
  spec {
    selector = {
      App = local.sql_proxy_label
    }
    session_affinity = "ClientIP"
    port {
      port        = local.db_port
      target_port = local.db_port
    }
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# CREATE CLUSTER SECRETS
# ---------------------------------------------------------------------------------------------------------------------

locals {
  sql_proxy_label              = "cloudsqlproxy"
  sql_proxy_name               = "terraform-sql-proxy"
  proxy_file_name              = "proxyCreds.json"
  proxy_file_path              = "${local.proxy_file_name}"
  proxy_volume_and_secret_name = "cloudsql-instance-credentials"

  # setting port to 5432 (default for Postgres) if the sql_version contains "postgres", otherwise 3306 (default for MySQL)
  detected_port = length(regexall("(.*POSTGRES.*)|(.*postgres.*)", var.sql_version)) > 0 ? 5432 : 3306

  # Prioritizing passed port unless 0 (default)
  db_port = var.sql_port != 0 ? var.sql_port : local.detected_port
}

resource "kubernetes_secret" "proxy-credentials" {
  count = var.sql_database ? 1 : 0

  metadata {
    name      = local.proxy_volume_and_secret_name
    namespace = "prod"
  }

  data = {
    (local.proxy_file_name) = file(local.proxy_file_path)
  }
}

resource "kubernetes_secret" "db-app" {
  count = var.sql_database ? 1 : 0

  metadata {
    name = "db-secrets"
  }

  data = {
    DB_HOST     = local.sql_proxy_name
    DB_PORT     = local.db_port
    DB_USER     = var.sql_user
    DB_PASSWORD = random_password.appuser.result
    DB_NAME     = var.sql_db_name
    DB_SSLMODE  = "disable" # connection to db is always encrypted by cloud sql proxy but intracluster communication is affected by this
  }

  depends_on = [random_password.appuser]
}

# Exporting db-admin as a Kubernetes secret, which may be fairly easily accessed by an admin.
resource "kubernetes_secret" "db-admin" {
  count = var.sql_database ? 1 : 0

  metadata {
    name = "db-admin"
  }

  data = {
    USERNAME = var.sql_admin
    PASSWORD = random_password.admin.result
  }

  depends_on = [random_password.admin]
}