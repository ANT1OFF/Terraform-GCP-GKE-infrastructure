resource "google_compute_global_address" "app-ip" {
    name = "app-static-ip-address"
}

#resource "google_dns_record_set" "app-ip" {
#    project = var.project_id 
#    managed_zone = google_dns_managed_zone.fonn-zone.name
#    name = "frontend.${google_dns_managed_zone.fonn-zone.name}"
#    type = "A"
#    ttl = 300
#    rrdatas = ["${google_compute_global_address.app-ip.address}"]
#}
#
#resource "google_dns_managed_zone" "fonn-zone" {
#    dns_name = "fonn.es."
#    name = "fonn-zone"
#}


resource "google_dns_record_set" "frontend" {
  name = "frontend.${google_dns_managed_zone.prod.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.prod.name

  rrdatas = [google_compute_global_address.app-ip.address]
}

resource "google_dns_managed_zone" "prod" {
  name     = "prod-zone"
  dns_name = "prod.mydomain.com."
}