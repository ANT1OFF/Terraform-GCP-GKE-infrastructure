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
| cert\_manager\_install | n/a | `bool` | `true` | no |
| cluster\_ca\_certificate | n/a | `any` | n/a | yes |
| cluster\_endpoint | n/a | `any` | n/a | yes |
| cluster\_name | Name of the cluster | `string` | n/a | yes |
| credentials | Credentials for the service account for Terraform to use when interacting with GCP | `string` | n/a | yes |
| nginx\_namespace | Namespace for the NGINX controller | `string` | `"nginx"` | no |
| project\_id | The project ID to host the cluster in | `string` | n/a | yes |
| region | The region to host the cluster in (optional if zonal cluster / required if regional) | `string` | `"europe-west1"` | no |
| vpc\_static\_ip | n/a | `any` | n/a | yes |

## Outputs

No output.

