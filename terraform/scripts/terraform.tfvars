project_id   = "bachelor-2020"
bucket_name  = "b2020-tf-state-dev"
credentials  = "../credentials.json"
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
