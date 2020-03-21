project_id   = "bachelor-2020"
region       = "europe-west1"
zone         = "europe-west1-b"
cluster_name = "tf-gke-cluster"
preemptible  = true
sql_database = false
sql_version  = "POSTGRES_11"
secrets      = {
   test = "true"
   env  = "scripts"
}
