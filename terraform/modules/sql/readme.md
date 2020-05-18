## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| google | n/a |
| kubernetes | n/a |
| random | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_ca\_certificate | n/a | `any` | n/a | yes |
| cluster\_endpoint | n/a | `any` | n/a | yes |
| credentials | Credentials for the service account for Terraform to use when interacting with GCP | `string` | n/a | yes |
| project\_id | The project ID to host the cluster in | `string` | n/a | yes |
| region | The region to host the cluster in (optional if zonal cluster / required if regional) | `string` | `"europe-west1"` | no |
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

## Outputs

No output.

