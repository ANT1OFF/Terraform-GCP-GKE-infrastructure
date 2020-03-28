resource "google_compute_global_address" "app-ip" {
    name = "app-static-ip-address"
}

resource "google_dns_record_set" "frontend" {
  name = "frontend.${google_dns_managed_zone.fonn.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.fonn.name

  rrdatas = [google_compute_global_address.app-ip.address]
}

resource "google_dns_managed_zone" "fonn" {
  name     = "fonn-zone"
  dns_name = "prod.fonn.es."
}