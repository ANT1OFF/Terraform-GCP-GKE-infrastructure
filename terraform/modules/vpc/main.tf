# terraform {
#   required_version = ">= 0.12.24"
#    backend "gcs" {
#     prefix  = "terraform/state/dev/vpc"
#   }
# }

# ---------------------------------------------------------------------------------------------------------------------
# PREPARE PROVIDERS
# ---------------------------------------------------------------------------------------------------------------------

provider "google" {
  version     = "~> 3.9.0"
  region      = var.region
  project     = var.project_id
  credentials = file(var.credentials)
}


# ---------------------------------------------------------------------------------------------------------------------
# CREATE A NETWORK 
# ---------------------------------------------------------------------------------------------------------------------

module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 2.1.1"

  project_id   = var.project_id
  network_name = var.network_name
  subnets = [
    {
      subnet_name           = var.subnet_name
      subnet_ip             = var.ip_range_sub
      subnet_region         = var.region
      subnet_private_access = "true"
    },
  ]
  secondary_ranges = {
    sub-02 = [
      {
        range_name    = "${var.subnet_name}-pods"
        ip_cidr_range = var.ip_range_pods
      },
      {
        range_name    = "${var.subnet_name}-services"
        ip_cidr_range = var.ip_range_services
      },
    ]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE FIREWALL RULES
# ---------------------------------------------------------------------------------------------------------------------

resource "google_compute_firewall" "fw-ingress-allow" {
  count     = length(var.firewall_ingress_allow) > 0 ? 1 : 0
  name      = "${module.vpc.network_name}-ingress-allow"
  network   = module.vpc.network_name
  direction = "INGRESS"

  dynamic "allow" {
    for_each = [for a in var.firewall_ingress_allow : {
      protocol = a.protocol
      ports    = a.ports
    }]

    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }

  source_tags = ["web"]
}
resource "google_compute_firewall" "fw-ingress-deny" {
  count     = length(var.firewall_ingress_deny) > 0 ? 1 : 0
  name      = "${module.vpc.network_name}-ingress-deny"
  network   = module.vpc.network_name
  direction = "INGRESS"
  dynamic "deny" {
    for_each = [for d in var.firewall_ingress_deny : {
      protocol = d.protocol
      ports    = d.ports
    }]

    content {
      protocol = deny.value.protocol
      ports    = deny.value.ports
    }
  }

  source_tags = ["web"]
}

resource "google_compute_firewall" "fw-egress-allow" {
  count     = length(var.firewall_egress_allow) > 0 ? 1 : 0
  name      = "${module.vpc.network_name}-egress-allow"
  network   = module.vpc.network_name
  direction = "EGRESS"

  dynamic "allow" {
    for_each = [for a in var.firewall_egress_allow : {
      protocol = a.protocol
      ports    = a.ports
    }]

    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }
}


resource "google_compute_firewall" "fw-egress-deny" {
  count     = length(var.firewall_egress_deny) > 0 ? 1 : 0
  name      = "${module.vpc.network_name}-egress-deny"
  network   = module.vpc.network_name
  direction = "EGRESS"

  dynamic "deny" {
    for_each = [for d in var.firewall_egress_deny : {
      protocol = d.protocol
      ports    = d.ports
    }]

    content {
      protocol = deny.value.protocol
      ports    = deny.value.ports
    }
  }
}