# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE CLUSTER
# ---------------------------------------------------------------------------------------------------------------------
locals {
  cluster_name = "deploy-service"
}

module "kubernetes-engine" {
  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "7.2.0"
  
  project_id = var.project_id
  name       = "${local.cluster_name}-cluster${var.cluster_name_suffix}"
  region     = var.region
  zones      = var.zone-for-cluster
  network    = module.vpc.network_name
  subnetwork = module.vpc.subnets_names[0]

  ip_range_pods          = module.vpc.subnets_secondary_ranges[0][0].range_name
  ip_range_services      = module.vpc.subnets_secondary_ranges[0][1].range_name
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

locals {
  app_label = "hello"
}

resource "kubernetes_deployment" "hello" {
  metadata {
    name = "terraform-hello"
    labels = {
      App = local.app_label
    }
  }

  spec {
    replicas = 6
    selector {
      match_labels = {
        App = local.app_label
      }
    }

    template {
      metadata {
        labels = {
          App = local.app_label
        }
      }

      spec {
        container {
          image = var.image_name
          name  = "hello"
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}


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
          image = "gcr.io/bachelor-2020/test-rest:v1.14"
          name  = "test-rest"
          port {
            container_port = 8080
          }
        }

        container {
          image = "gcr.io/cloudsql-docker/gce-proxy:1.16"
          name = "sql-proxy"
          port {
            container_port = 5432 # swap for mysql
          }
          command = ["/cloud_sql_proxy",
                      "-instances=${google_sql_database_instance.master[0].connection_name}=tcp:5432",
                      "-credential_file=/secrets/cloudsql/proxyCreds.json"]
          volume_mount {
            name = "cloudsql-instance-credentials"
            mount_path = "/secrets/cloudsql"
            read_only = true
          }
        }

        volume {
          name = "cloudsql-instance-credentials"
          secret {
            secret_name = "cloudsql-instance-credentials"
          }
        }
      }
    }
  }
}



resource "kubernetes_secret" "proxy-credentials" {
  metadata {
    name = "cloudsql-instance-credentials"
  }

  data = {
    "proxyCreds.json" = file("proxyCreds.json")
  }
}