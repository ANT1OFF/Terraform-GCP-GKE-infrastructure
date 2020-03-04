remote_state {
  backend = "gcs"
  config = {
    location    = "eu"
    project     = "bachelor-2020"
    bucket      = "b2020_terraform-state"
    credentials = "${get_terragrunt_dir()}/${find_in_parent_folders("credentials.json")}"
    prefix      = "${path_relative_to_include()}/terraform.tfstate"
  }
}

inputs = {
  project_id = "bachelor-2020"
  region     = "europe-west1"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "google" {
  version = "~> 3.9.0"
  region  = var.region
  project = var.project_id
  credentials = file("../../credentials.json")
}
EOF
}