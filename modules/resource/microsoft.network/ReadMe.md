# Network

Manages a virtual network including any configured subnets. Each subnet can optionally be configured with a security group to be associated with the subnet.

## Example Usage

```json
"parameters": {
  "name": {
    "value": "[reference(concat(deployment().name, '-gov')).outputs.defaultConvention.value]"
  },
  "environment": {
    "value": "[parameters('environment')]"
  },
  "contactEmail": {
    "value": "[parameters('contactEmail')]"
  },
  "networkSettings": {
    "value": {
      "addressSpace": "10.10.0.0/16",
      "subnets": [
        {
          "name": "private",
          "description": "allow RDP connections",
          "addressPrefix": "10.10.0.0/24"
        }
      ]
    }
  }
}
```

## Argument Reference
The following arguments are supported:


|Property        | Type   | Mandatory|Default |Sample|Description
|---|---|---|---|---|---|
|Name            | string |yes |bm   |my-project-{resourcetype}   | Resource Naming Template
|projectName     | string |Yes |     |myProject      | The Project name we are deploying
|environment     | string |no  |Dev  |Prod|Test|Dev|POC | The Environment type we are deploying
|contact         | string |no  |     |user@company.com | The primary contact for these resources
|networkSettings | object |yes |     |JSON object defining the network and subnet configuration

## Attributes Reference
The following attributes are exported:

|Property          | type  | Sample |Description
|---|---|---|---|
|defaultConvention | string | bm-demo-{resourceType}-Dev-ne |Template for naming normal Resources
|storageConvention | string | bmdemo{resourceType}Devne     |Template for naming Storage Resources

## Import

Resource Groups can be imported using the resource id, e.g.

```bash
az group deployment create -g BM-Demo01 --template-uri https://raw.githubusercontent.com/DamianFlynn/arm/master/modules/governance/governance.naming/azuredeploy.json --parameters '{\"companyName\": {\"value\": \"bm\"},\"projectName\": {\"value\": \"myProject\"},\"environment\": {\"value\": \"Test\"}}'
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
    "mode": "complete",
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
