# Naming Convention

The is a special template which is designed to establish resource names based on the defined naming standards issued in Governance.

The template deploys **NO Resources**. The template will accept a number of parameters, which will be transposed to establish the pattern for the naming of all other resources to be deployed.

## Example Usage

```json
resource "azurerm_resource_group" "test" {
  name     = "testResourceGroup1"
  location = "West US"

  tags {
    environment = "Production"
  }
}
```

## Argument Reference
The following arguments are supported:


|Property        | Type   | Mandatory|Default |Sample|Description
|---|---|---|---|---|---|
|companyName     | string |no  |bm   |Wizz           | The ID used to identify the organisation
|projectName     | string |Yes |     |myProject      | The Project name we are deploying
|environment     | string |no  |Dev  |Prod|Test|Dev|POC | The Environment type we are deploying


## Attributes Reference
The following attributes are exported:

|Property          | type  | Sample |Description
|---|---|---|---|
|defaultConvention | string | bm-demo-{resourceType}-Dev-ne |Template for naming normal Resources
|storageConvention | string | bmdemo{resourceType}Devne     |Template for naming Storage Resources

## Import

Resource Groups can be imported using the resource id, e.g.

```bash
az group deployment create -g BM-Demo01 --template-uri https://raw.githubusercontent.com/DamianFlynn/arm/master/NamingConvention/namingConvention.json --parameters '{\"companyName\": {\"value\": \"bm\"},\"projectName\": {\"value\": \"myProject\"},\"environment\": {\"value\": \"Test\"}}'
```

```json
{
  "id": "/subscriptions/85dd1a3b-3a9b-46de-b62f-6bbb7da927aa/resourceGroups/BM-Demo01/providers/Microsoft.Resources/deployments/naming-convention",
  "location": null,
  "name": "naming-convention",
  "properties": {
    "correlationId": "3a2ec4dc-c8b5-4a9a-87ae-8ec9c917400e",
    "debugSetting": null,
    "dependencies": [],
    "duration": "PT4.3722711S",
    "mode": "Incremental",
    "onErrorDeployment": null,
    "outputResources": [],
    "outputs": {
      "defaultConvention": {
        "type": "String",
        "value": "bm-demo-{resourceType}-Test-ne"
      },
      "storageConvention": {
        "type": "String",
        "value": "bmdemo{resourceType}testne"
      }
    },
    "parameters": {
      "companyName": {
        "type": "String",
        "value": "bm"
      },
      "environment": {
        "type": "String",
        "value": "Test"
      },
      "projectName": {
        "type": "String",
        "value": "demo"
      }
    },
    "parametersLink": null,
    "providers": [],
    "provisioningState": "Succeeded",
    "template": null,
    "templateHash": "4810215207157976159",
    "templateLink": null,
    "timestamp": "2019-01-11T10:10:26.557199+00:00"
  },
  "resourceGroup": "BM-Demo01"
}
```
