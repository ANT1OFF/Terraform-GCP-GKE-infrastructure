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
  name     = var.sql_db_name
  instance = google_sql_database_instance.master[0].name
}

resource "google_sql_user" "users" {
  name     = var.sql_user
  instance = google_sql_database_instance.master[0].name
  password = random_password.db_password.result
}

resource "random_password" "db_password" {
  length = 16
}