# Terraform templates for automatic deployment of applications to Google Cloud Platforms' Kubernetes engine

This repository is part of a bachelor thesis done by four students at NTNU Gjøvik. As the title states, the repo aims to automate deployment of complex applications to GCPs' Kubernetes Engine.

Currently this repo is for testing purposes only as we explore technologies to use for solving the thesis' main issue. In this repo we try to deploy using Hashicorps' Terraform.

## Prerequisites

- A Google Cloud Platform project with suitable a suitable funding solution.

- A GCS bucket to remotely store the Terraform state. Change the name of the bucket in **backend.tf** and **terraform.tfvars** in **terraform/scripts/** to the name of your bucket.

- Service account with the following roles (may be reduced at a later date):
    - Kubernetes Engine Admin
    - Editor
    - Project IAM Admin

  Download the credentialsfor the service account in json format, rename the file "**credentials.json**" and place it in under *terraform/dev*. This service account is used to authenticate the remote backend in GCS and as credentials for the various Google providers in the repository.

- Service account with the role **Cloud SQL Client**. Download the credentials for the service account in json format, rename the file **proxyCreds.json** and place it under *terraform/dev*. This service account is used to authenticate the Cloud SQL Proxy. 


## Connect to Argo UI
```kubectl port-forward svc/argocd-server -n argocd 8080:443```