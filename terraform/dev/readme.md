## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.24 |

## Providers

No provider.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| argocd\_ingress | If argocd shall be reachable from argocd.domain | `bool` | `true` | no |
| argocd\_namespace | Namespace for ArgoCD | `string` | `"argocd"` | no |
| cert\_manager\_install | If cert-manager shall be installed alongside nginx | `bool` | `true` | no |
| cluster\_name | Name of the cluster | `string` | `"tf-gke-cluster-default"` | no |
| credentials | Credentials for the service account for Terraform to use when interacting with GCP | `string` | n/a | yes |
| demo\_app | If demo apps shall be deployed to argocd | `bool` | `true` | no |
| domain | The domain for the project, for instance example.com | `string` | `"example.com"` | no |
| firewall\_egress\_allow | The list of egress ALLOW rules specified by the firewall. Ports must be either an integer or a range. | <pre>list(object({<br>    protocol = string<br>    ports    = list(string)<br>  }))</pre> | `[]` | no |
| firewall\_egress\_deny | The list of egress DENY rules specified by the firewall. Ports must be either an integer or a range. | <pre>list(object({<br>    protocol = string<br>    ports    = list(string)<br>  }))</pre> | `[]` | no |
| firewall\_ingress\_allow | The list of ingress ALLOW rules specified by the firewall. Ports must be either an integer or a range. | <pre>list(object({<br>    protocol = string<br>    ports    = list(string)<br>  }))</pre> | <pre>[<br>  {<br>    "ports": [<br>      "80",<br>      "443"<br>    ],<br>    "protocol": "tcp"<br>  }<br>]</pre> | no |
| firewall\_ingress\_deny | The list of ingress DENY rules specified by the firewall. Ports must be either an integer or a range. | <pre>list(object({<br>    protocol = string<br>    ports    = list(string)<br>  }))</pre> | `[]` | no |
| ip\_range\_pods | IP range available for the pods | `string` | `"192.168.0.0/18"` | no |
| ip\_range\_services | IP range available for the services | `string` | `"192.168.64.0/18"` | no |
| ip\_range\_sub | The IP and CIDR range of the subnet being created | `string` | `"10.0.0.0/17"` | no |
| machine\_type | The name of a Google Compute Engine machine type to use in the node pool | `string` | `"n1-standard-1"` | no |
| network\_name | The name of the VPC being created | `string` | `"vpc-network"` | no |
| nginx\_namespace | Namespace for the NGINX controller | `string` | `"nginx"` | no |
| preemptible | A boolean that represents whether or not the underlying node VMs are preemptible | `bool` | `false` | no |
| project\_id | The project ID to host the cluster in | `string` | n/a | yes |
| region | The region to host the cluster in (optional if zonal cluster / required if regional) | `string` | `"europe-west1"` | no |
| secrets | Secrets referr to arbitrary secrets to be injected as Kubernetes secrets, which may be passed to an application as demonstrated with db-secrets in the example app deployment definition yaml | `map(string)` | `{}` | no |
| sql\_admin | Name for the sql admin account. | `string` | `"admin"` | no |
| sql\_autoresize | Configuration to increase storage size automatically | `bool` | `true` | no |
| sql\_availability | Specifies whether a PostgreSQL instance should be set up for high availability (REGIONAL) or single zone (ZONAL). Only available for PostgreSQL instances. | `string` | `"ZONAL"` | no |
| sql\_backup\_config | The backup\_configuration settings subblock for the database setings. Binary log may only be enabled for MySQL instances. | <pre>object({<br>    binary_log_enabled = bool<br>    enabled            = bool<br>    start_time         = string<br>  })</pre> | <pre>{<br>  "binary_log_enabled": null,<br>  "enabled": false,<br>  "start_time": null<br>}</pre> | no |
| sql\_database | Whether or not a database should be provisioned | `bool` | `false` | no |
| sql\_db\_name | Name for the sql database for use by applications. | `string` | `"default_db_name"` | no |
| sql\_disk\_size | The size of data disk, in GB. Size of a running instance cannot be reduced but can be increased | `number` | `10` | no |
| sql\_disk\_type | The type of data disk: PD\_SSD or PD\_HDD | `string` | `"PD_SSD"` | no |
| sql\_name | The name of the database | `string` | `"terraform-db"` | no |
| sql\_port | The port used by the database and SQL proxy. This will also be exported as a kubernetes secret. If left to default, it will be interpreted based on sql\_version | `number` | `0` | no |
| sql\_replica\_count | Number of read replicas. Note, this requires the master to have binary\_log\_enabled set, as well as existing backups. | `number` | `0` | no |
| sql\_tier | The machine type to use | `string` | `"db-f1-micro"` | no |
| sql\_user | Name for the sql account for use by applications. | `string` | `"appuser"` | no |
| sql\_version | The database version to run. See https://cloud.google.com/sql/docs/sqlserver/db-versions for available versions | `string` | `"POSTGRES_11"` | no |
| subnet\_name | The name of the subnet being created | `string` | `"vpc-subnet"` | no |
| zone\_for\_cluster | The zones to host the cluster in (optional if regional cluster / required if zonal) | `list(string)` | <pre>[<br>  "europe-west1-b"<br>]</pre> | no |

## Outputs

No output.

