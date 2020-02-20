# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE CLUSTER
# ---------------------------------------------------------------------------------------------------------------------


module "kubernetes-engine" {
  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "7.2.0"
  
  project_id = var.project_id
  name       = "${local.cluster_type}-cluster${var.cluster_name_suffix}"
  region     = var.region
  zones      = var.zone-for-cluster
  network    = module.vpc.network_name
  subnetwork = module.vpc.subnets_names[0]

  ip_range_pods          = module.vpc.subnets_secondary_ranges[0][0].range_name
  ip_range_services      = module.vpc.subnets_secondary_ranges[0][1].range_name

  node_pools = [
    {
      name               = "default-node-pool"
      machine_type       = "n1-standard-2"
      min_count          = 1
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
      App = "${kubernetes_deployment.hello.spec[0].template[0].metadata[0].labels.App}"
    }
    session_affinity = "ClientIP"
    port {
      port        = 80
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_deployment" "hello" {
  metadata {
    name = "terraform-hello"
    labels = {
      App = "hello"
    }
  }

  spec {
    replicas = 6
    selector {
      match_labels = {
        App = "hello"
      }
    }

    template {
      metadata {
        labels = {
          App = "hello"
        }
      }

      spec {
        container {
          image = "gcr.io/bachelor-2020/hello-world@sha256:52cd3259e461429ea5123623503920622fad5deb57f44e14167447d1cb1c777b"
          name  = "hello"
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}
