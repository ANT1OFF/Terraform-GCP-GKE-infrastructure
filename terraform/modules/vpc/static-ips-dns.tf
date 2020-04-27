resource "google_dns_managed_zone" "domain" {
  name     = "domain-zone"
  dns_name = "${var.domain}."
}


resource "google_dns_record_set" "argocd" {
  name = "argocd.${google_dns_managed_zone.domain.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.domain.name
  rrdatas      = [google_compute_address.app-ip.address]
}

resource "google_dns_record_set" "rollout" {
  name = "rollout.${google_dns_managed_zone.domain.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.domain.name
  rrdatas      = [google_compute_address.app-ip.address]
}

resource "google_dns_record_set" "srollout" {
  name = "staging.rollout.${google_dns_managed_zone.domain.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.domain.name
  rrdatas      = [google_compute_address.app-ip.address]
}


resource "google_dns_record_set" "main" {
  name = google_dns_managed_zone.domain.dns_name
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.domain.name
  rrdatas      = [google_compute_address.app-ip.address]
}

resource "google_compute_address" "app-ip" {
  name   = "app-static-ip-address"
  region = var.region
}

