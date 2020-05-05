## Requirements

| Name | Version |
|------|---------|
| google | ~> 3.9.0 |

## Providers

| Name | Version |
|------|---------|
| google | ~> 3.9.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| argocd\_ingress | If argocd shall be reachable from argocd.domain | `bool` | `true` | no |
| credentials | Credentials for the service account for Terraform to use when interacting with GCP | `string` | n/a | yes |
| domain | The domain for the project, for instance example.com | `string` | `"example.com"` | no |
| firewall\_egress\_allow | The list of egress ALLOW rules specified by the firewall. Ports must be either an integer or a range. | <pre>list(object({<br>    protocol = string<br>    ports    = list(string)<br>  }))</pre> | `[]` | no |
| firewall\_egress\_deny | The list of egress DENY rules specified by the firewall. Ports must be either an integer or a range. | <pre>list(object({<br>    protocol = string<br>    ports    = list(string)<br>  }))</pre> | `[]` | no |
| firewall\_ingress\_allow | The list of ingress ALLOW rules specified by the firewall. Ports must be either an integer or a range. | <pre>list(object({<br>    protocol = string<br>    ports    = list(string)<br>  }))</pre> | <pre>[<br>  {<br>    "ports": [<br>      "80",<br>      "443"<br>    ],<br>    "protocol": "tcp"<br>  }<br>]</pre> | no |
| firewall\_ingress\_deny | The list of ingress DENY rules specified by the firewall. Ports must be either an integer or a range. | <pre>list(object({<br>    protocol = string<br>    ports    = list(string)<br>  }))</pre> | `[]` | no |
| ip\_range\_pods | IP range available for the pods | `string` | `"192.168.0.0/18"` | no |
| ip\_range\_services | IP range available for the services | `string` | `"192.168.64.0/18"` | no |
| ip\_range\_sub | The IP and CIDR range of the subnet being created | `string` | `"10.0.0.0/17"` | no |
| network\_name | The name of the VPC being created | `string` | `"vpc-network"` | no |
| project\_id | The project ID to host the cluster in | `string` | n/a | yes |
| region | The region to host the cluster in (optional if zonal cluster / required if regional) | `string` | `"europe-west1"` | no |
| subnet\_name | The name of the subnet being created | `string` | `"vpc-subnet"` | no |

## Outputs

| Name | Description |
|------|-------------|
| network-name | Name of network |
| network-subnets | network-subnets |
| static-ip | static ip |

