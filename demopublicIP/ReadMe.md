# Public IP Address

This template will deploy a new Public IP address resource

## Paramaters

|Property| Type | Mandatory|Default|Sample|Description
|---|---|---|---|---|---|
|name | string | Yes | |my-service-pip | The name to assoicated with your Public IP Resource
|location | string |No | eastus | northeurope | The Azure Datacenter location which we are targeting

## Outputs

|Property | type | Description
|---|---|---|
|resourceID | string | The full resource identification string of the deployed resource |
