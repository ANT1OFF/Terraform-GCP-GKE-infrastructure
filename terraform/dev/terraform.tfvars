project_id = "bachelor-2020"
region = "europe-west1"
zone = "europe-west1-b"

cluster_name = "tf-gke-cluster"
cluster_name_suffix = ""
zone-for-cluster = ["europe-west1-b"]

network_name = "vpc-network"
subnet_name = "vpc-subnet"
ip_range_sub = "10.10.10.0/24"
ip_range_pods = "10.10.11.0/24"
ip_range_services = "10.10.12.0/24"

ingress = true
image_name = "gcr.io/bachelor-2020/hello-world@sha256:52cd3259e461429ea5123623503920622fad5deb57f44e14167447d1cb1c777b"

sql_version = "POSTGRES_11"
sql_database = true