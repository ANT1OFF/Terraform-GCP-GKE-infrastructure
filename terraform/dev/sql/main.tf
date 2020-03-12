terraform {
  required_version = ">= 0.12.20"
   backend "gcs" {
    bucket  = "b2020-tf-state-dev"  # TODO: make variable or similar?
    prefix  = "terraform/state/dev/sql"
    credentials = "../credentials.json"
  }
}

# TODO: allow sql database to be applied simultaniously with cluster. Currently it needs to be applied after cluster to insert k8s secrets into the cluster

# ---------------------------------------------------------------------------------------------------------------------
# PREPARE PROVIDERS
# ---------------------------------------------------------------------------------------------------------------------

provider "google" {
  version = "~> 3.9.0"
  region  = var.region
  project = var.project_id
  credentials = file("../credentials.json")
}

provider "google-beta" {
  region  = var.region
  project = var.project_id
  credentials = file("../credentials.json")
}


# ---------------------------------------------------------------------------------------------------------------------
# Create Database 
# ---------------------------------------------------------------------------------------------------------------------

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

# TODO: export password to some secure location to allow operators to log into the database. Maybe add a seperate account for this
resource "random_password" "appuser" {
  length = 24
}

resource "random_password" "admin" {
  length = 24
}

# ---------------------------------------------------------------------------------------------------------------------
# Create Kubernetes stuff 
# ---------------------------------------------------------------------------------------------------------------------

data "terraform_remote_state" "main" {
  backend = "gcs"

  config = {
    bucket  = "b2020-tf-state-dev"
    prefix  = "terraform/state"
    credentials = "../credentials.json"
  }
}

# based on https://github.com/GoogleCloudPlatform/cloudsql-proxy/blob/master/Kubernetes.md
provider "kubernetes" {
  load_config_file       = false
  host                   = "https://${data.terraform_remote_state.main.outputs.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.terraform_remote_state.main.outputs.ca_certificate)
}
data "google_client_config" "default" {
}

resource "kubernetes_deployment" "sql-proxy" {
  count = var.sql_database ? 1 : 0

  metadata {
    name = "terraform-sql-proxy"
    labels = {
      App = local.sql_proxy_label
    }
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
          name = "sql-proxy"
          command = ["/cloud_sql_proxy",
                      "-dir=/cloudsql",
                      "-instances=${google_sql_database_instance.master[0].connection_name}=tcp:0.0.0.0:5432",  # additional databases may be included here
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
            name = local.proxy_volume_and_secret_name
            mount_path = "/secrets/cloudsql"
            read_only = true
          }

          volume_mount {
            name = "cloudsql"
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
    name = local.sql_proxy_name
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
  sql_proxy_label = "cloudsqlproxy"
  sql_proxy_name = "terraform-sql-proxy"
  proxy_file_name = "proxyCreds.json"
  proxy_file_path = "../${local.proxy_file_name}"
  proxy_volume_and_secret_name ="cloudsql-instance-credentials"
  db_port = 5432
  # length(regexall(".*POSTGRES.*", var.sql_version)) > 0 ? 5432 : 3306 # TODO: fix
}

resource "kubernetes_secret" "proxy-credentials" {
  count = var.sql_database ? 1 : 0

  metadata {
    name = local.proxy_volume_and_secret_name
  }

  data = {
    (local.proxy_file_name) = file(local.proxy_file_path)
  }
}

resource "kubernetes_secret" "database" {
  count = var.sql_database ? 1 : 0

  metadata {
    name = "db-secrets"
  }

  # TODO: add dynamic secrets
  data = {
    DB_HOST = local.sql_proxy_name
    DB_PORT = local.db_port
    DB_USER = var.sql_user
    DB_PASSWORD = random_password.appuser.result
    DB_NAME = var.sql_db_name
    DB_SSLMODE = "disable" # communication is encrypted by sql-proxy
  }

  depends_on = [random_password.appuser]
}


resource "google_secret_manager_secret" "sql" {
  count = var.sql_database ? 1 : 0
  provider = google-beta

  secret_id = "sql-secrets"

  labels = {
    label = "sql-secrets"
  }

  replication {
    automatic = true
  }
}


resource "google_secret_manager_secret_version" "sql-user" {
  count = var.sql_database ? 1 : 0
  provider = google-beta

  secret = google_secret_manager_secret.sql[0].id
  secret_data = "username: ${var.sql_admin} password: ${random_password.admin.result}"
}

# resource "google_secret_manager_secret_version" "sql-password" {
#   provider = google-beta

#   secret = google_secret_manager_secret.sql.id

#   secret_data = random_password.admin.result
# }