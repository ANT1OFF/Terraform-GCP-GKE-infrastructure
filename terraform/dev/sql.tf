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
  name     = "my_db"
  instance = google_sql_database_instance.master[0].name
}

resource "google_sql_user" "users" {
  name     = "test"
  instance = google_sql_database_instance.master[0].name
  password = "testPass"
}