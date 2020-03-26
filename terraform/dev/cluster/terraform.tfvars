cluster_name = "tf-gke-cluster"
zone-for-cluster = ["europe-west1-b"]

project_id="bachelor-2020"
region="europe-west1"
zone="europe-west1-b"

# This is just an example to demonstrate arbitrary Kubernetes secrets
secrets = {
   test = "true"
   env = "tfvars"
}