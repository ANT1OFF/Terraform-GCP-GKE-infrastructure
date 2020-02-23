# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE CLUSTER
# ---------------------------------------------------------------------------------------------------------------------
locals {
  cluster_name = "deploy-service"
}

data "google_compute_subnetwork" "subnetwork" {
  name       = var.network_name
  project    = var.project_id
  region     = var.region
  depends_on = [module.vpc]
}

module "kubernetes-engine" {
  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "7.2.0"
  
  project_id = var.project_id
  name       = "${local.cluster_name}-cluster${var.cluster_name_suffix}"
  region     = var.region
  zones      = var.zone-for-cluster

  # fake a dependency on vpc network
  # force cluster creation to wait on network creation without a
  # depends_on link (still not implemented in 0.12)
  network    = reverse(split("/", data.google_compute_subnetwork.subnet.network))[0]
  subnetwork = module.vpc.subnets_names[0]

  ip_range_pods              = "${local.subnet_name}-pods" #module.vpc.subnets_secondary_ranges[0][0].range_name
  ip_range_services          = "${local.subnet_name}-services" #module.vpc.subnets_secondary_ranges[0][1].range_name
  horizontal_pod_autoscaling = true

  node_pools = [
    {
      name               = "default-node-pool"
      machine_type       = "n1-standard-2"  # TODO: make variable ?
      min_count          = 3
      max_count          = 100
      image_type         = "COS"
      auto_repair        = true
      auto_upgrade       = true
      service_account    = module.service_accounts.email
    },
  ]
}


# ---------------------------------------------------------------------------------------------------------------------
# CREATE RECURCES IN THE CLUSTER
# ---------------------------------------------------------------------------------------------------------------------


resource "kubernetes_service" "hello-world" {
  count = var.ingress ? 1 : 0
  metadata {
    name = "terraform-hello-world"
  }
  spec {
    selector = {
      #App = "${kubernetes_deployment.hello.spec[0].template[0].metadata[0].labels.App}"
      App = local.app_label2
    }
    session_affinity = "ClientIP"
    port {
      port        = 80
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# CREATE DEPLOYMENT IN THE CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

locals {
  app_label2 = "test-rest"
}

resource "kubernetes_deployment" "test-rest" {
  metadata {
    name = "terraform-test-rest"
    labels = {
      App = local.app_label2
    }
  }

  spec {
    replicas = 6
    selector {
      match_labels = {
        App = local.app_label2
      }
    }

    template {
      metadata {
        labels = {
          App = local.app_label2
        }
      }

      spec {
        container {
          image = "gcr.io/bachelor-2020/test-rest:v1.15"
          name  = "test-rest"
          port {
            container_port = 8080
          }

          # TODO: make dynamic (including names of secrets), allow for passing secrets by other means
          env {
            name = "DB_HOST"
            value = "localhost" # should connect to sql proxy
          }
          env {
            name = "DB_PORT"
            # setting port to 5432 if sql_version contains "POSTGRES", otherwise 3306 (mysql standard port)
            value = length(regexall(".*POSTGRES.*", var.sql_version)) > 0 ? 5432 : 3306
          }
          env {
            name = "DB_USER"
            value = var.sql_user
          }
          env {
            name = "DB_PASSWORD"
            value = random_password.db_password.result
          }
          env {
            name = "DB_NAME"
            value = var.sql_db_name
          }
          env {
            name = "DB_SSLMODE"
            value = "disable" # communication is encrypted by sql-proxy
          }
        }

        container {
          image = "gcr.io/cloudsql-docker/gce-proxy:1.16"
          name = "sql-proxy"
          port {
            container_port = length(regexall(".*POSTGRES.*", var.sql_version)) > 0 ? 5432 : 3306
          }
          command = ["/cloud_sql_proxy",
                      "-instances=${google_sql_database_instance.master[0].connection_name}=tcp:5432",
                      "-credential_file=/secrets/cloudsql/${local.proxy_file_name}"]
          volume_mount {
            name = local.proxy_volume_and_secret_name
            mount_path = "/secrets/cloudsql"
            read_only = true
          }
        }

        volume {
          name = local.proxy_volume_and_secret_name
          secret {
            secret_name = local.proxy_volume_and_secret_name
          }
        }
      }
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE CLUSTER SECRETS
# ---------------------------------------------------------------------------------------------------------------------

locals {
  proxy_file_name = "proxyCreds.json"
  proxy_volume_and_secret_name ="cloudsql-instance-credentials"
}

resource "kubernetes_secret" "proxy-credentials" {
  metadata {
    name = local.proxy_volume_and_secret_name
  }

  data = {
    (local.proxy_file_name) = file(local.proxy_file_name)
  }
}


