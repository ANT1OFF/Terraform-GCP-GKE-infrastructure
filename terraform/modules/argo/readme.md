## Requirements

| Name | Version |
|------|---------|
| google | ~> 3.9.0 |

## Providers

| Name | Version |
|------|---------|
| google | ~> 3.9.0 |
| helm | n/a |
| kubernetes | n/a |
| null | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| argocd\_ingress | If argocd shall be reachable from argocd.domain | `bool` | `true` | no |
| argocd\_namespace | Namespace for ArgoCD | `string` | `"argocd"` | no |
| cluster\_ca\_certificate | n/a | `any` | n/a | yes |
| cluster\_endpoint | n/a | `any` | n/a | yes |
| cluster\_name | Name of the cluster | `string` | n/a | yes |
| credentials | Credentials for the service account for Terraform to use when interacting with GCP | `string` | n/a | yes |
| demo\_app | n/a | `bool` | `true` | no |
| project\_id | The project ID to host the cluster in | `string` | n/a | yes |
| region | The region to host the cluster in (optional if zonal cluster / required if regional) | `string` | `"europe-west1"` | no |

## Outputs

No output.

