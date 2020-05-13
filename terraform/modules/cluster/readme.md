## Requirements

| Name | Version |
|------|---------|
| google | ~> 3.9.0 |

## Providers

| Name | Version |
|------|---------|
| google | ~> 3.9.0 |
| kubernetes | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_name | Name of the cluster | `string` | `"tf-gke-cluster-default"` | no |
| credentials | Credentials for the service account for Terraform to use when interacting with GCP | `string` | n/a | yes |
| machine\_type | The name of a Google Compute Engine machine type to use in the node pool | `string` | `"n1-standard-1"` | no |
| network\_name | Name of the VPC network | `any` | n/a | yes |
| network\_subnets | Subnets to use | `any` | n/a | yes |
| preemptible | A boolean that represents whether or not the underlying node VMs are preemptible | `bool` | `false` | no |
| project\_id | The project ID to host the cluster in | `string` | n/a | yes |
| region | The region to host the cluster in (optional if zonal cluster / required if regional) | `string` | `"europe-west1"` | no |
| secrets | Secrets referr to arbitrary secrets to be injected as Kubernetes secrets, which may be passed to an application as demonstrated with db-secrets in the example app deployment definition yaml | `map(string)` | `{}` | no |
| zone\_for\_cluster | The zones to host the cluster in (optional if regional cluster / required if zonal) | `list(string)` | <pre>[<br>  "europe-west1-b"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| ca\_certificate | Cluster ca certificate (base64 encoded) |
| cluster\_name | Name of the cluster |
| endpoint | Cluster endpoint |
