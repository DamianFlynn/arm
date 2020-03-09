function get-aztoken {
  $azContext = Get-AzContext
  $azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
  $profileClient = New-Object -TypeName Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient -ArgumentList ($azProfile)
  $token = $profileClient.AcquireAccessToken($azContext.Subscription.TenantId)
  $authHeader = @{
    'Content-Type'='application/json'
    'Authorization'='Bearer ' + $token.AccessToken
  }
  
  return $authHeader
}


function Get-BlueprintVersions {
  param(
    [string]$blueprint,
    [string]$managementGroup
  )

  $restUri= "https://management.azure.com/providers/Microsoft.Management/managementGroups/$managementGroup/providers/Microsoft.Blueprint/blueprints/$blueprint/versions?api-version=2018-11-01-preview"
  $response = Invoke-RestMethod -Uri $restUri -Method GET -Headers (get-aztoken)
  return $response
}


function New-Blueprint {
  param(
    [string]$file,
    [string]$name,
    [string]$managementGroup
  )
  
  $body = Get-Content -path $file 
  $restUri = "https://management.azure.com/providers/Microsoft.Management/managementGroups/$managementGroup/providers/Microsoft.Blueprint/blueprints/"+$name+"?api-version=2018-11-01-preview"
  $response = Invoke-RestMethod -Uri $restUri -Method Put -Headers (get-aztoken) -Body $body
  return $response
}


function Get-BlueprintArtifacts {
  param(
    [string]$blueprint,
    [string]$managementGroup
  )

  $restUri= "https://management.azure.com/providers/Microsoft.Management/managementGroups/$managementGroup/providers/Microsoft.Blueprint/blueprints/$blueprint/artifacts?api-version=2018-11-01-preview"
  $response = Invoke-RestMethod -Uri $restUri -Method GET -Headers (get-aztoken) 
  return $response
}


function Add-BlueprintArtifact {
  param(
    [string]$file,
    [string]$blueprint,
    [string]$name,
    [string]$managementGroup
  )

  $body = Get-Content -path $file 
  $restUri = "https://management.azure.com/providers/Microsoft.Management/managementGroups/$managementGroup/providers/Microsoft.Blueprint/blueprints/$blueprint/artifacts/"+$name+"?api-version=2018-11-01-preview"
  $response = Invoke-RestMethod -Uri $restUri -Method PUT -Headers (get-aztoken) -Body $body
  return $response
}



function Publish-Blueprint {
  param(
    [string]$blueprint,
    [string]$version,
    [string]$managementGroup
  )

  $restUri= "https://management.azure.com/providers/Microsoft.Management/managementGroups/$managementGroup/providers/Microsoft.Blueprint/blueprints/$blueprint/versions/"+$version+"?api-version=2018-11-01-preview"
  $response = Invoke-RestMethod -Uri $restUri -Method PUT -Headers (get-aztoken) 
  return $response
}


function Add-AzRBACRole {
  param (
    [string]$subscriptionID,
    [string]$roleDefinitionId,
    [string]$spn
  )
  
  $rbacbody = '{"properties": {"roleDefinitionId": "/subscriptions/'+$subscriptionId+'/providers/Microsoft.Authorization/roleDefinitions/'+$roleDefinitionId+'","principalId": "'+$spn+'"}}'
  $Id = [GUID]::NewGuid()

  $restUri = "https://management.azure.com/subscriptions/$subscriptionId/providers/Microsoft.Authorization/roleAssignments/"+$Id+"?api-version=2015-07-01"
  $response = Invoke-RestMethod -Uri $restUri -Method PUT -Headers (get-aztoken) -Body $rbacbody
  return $response
}

function Assign-Blueprint {
  param(
    [string]$subscriptionID,
    [string]$assignmentName,
    [string]$parametersFile,
    [string[]]$peerSubscriptions = $null
  )

  $body = Get-Content -Path $parametersFile
  $authHeader = get-aztoken
  ## Check the current AppID for the Blueprint RP
  try {
  $restUri = "https://management.azure.com/subscriptions/$subscriptionID/providers/Microsoft.Blueprint/blueprintAssignments/"+$assignmentName+"/whoIsBlueprint?api-version=2018-11-01-preview"
  $response = Invoke-RestMethod -Uri $restUri -Method POST -Headers $authHeader
  $spn = $response.objectId
  }

  catch [Exception] {
    write-host  $_.Exception|format-list -force
  }
  
  ## Query the subscription for current objects with Owner Privilages?
  $restUri = "https://management.azure.com/subscriptions/$subscriptionID/providers/Microsoft.Authorization/roleAssignments?api-version=2018-01-01-preview "
  $response = Invoke-RestMethod -Uri $restUri -Method GET -Headers $authHeader

  ## Determine if Bluepints has Owner Privilages Currently
  $roleDefinitionId = "8e3af657-a8ff-443c-a75c-2fe8c4bcb635"
  $roleAssigned = $false
  foreach ($assignment in $response.value){
    if ($assignment.properties.principalId -eq $spn -and
        $assignment.properties.roleDefinitionId.Split("/")[-1] -eq $roleDefinitionId ) 
    {
      Write-Host "Blueprint SPN is Subscription Owner"
      $roleAssigned = $true
      break
    } 
  }
  
  ## Provide the blueprint with Owner privialges, if required
  if (! $roleAssigned) {

    $rbac = Add-AzRBACRole -subscriptionID $subscriptionID -roleDefinitionId $roleDefinitionId -spn $spn

  }
  
  # With all the privilages checked, finally assign the Blueprint
  $restUri = "https://management.azure.com/subscriptions/$subscriptionID/providers/Microsoft.Blueprint/blueprintAssignments/"+$assignmentName+"?api-version=2018-11-01-preview"
  $response = Invoke-RestMethod -Uri $restUri -Method PUT -Headers $authHeader -Body $body

  Start-Sleep -Seconds 5

  ## Delegate the Blueprint access to peer subscriptions, eg Management and Hub Subscription
  foreach($sub in $peerSubscriptions){
    Write-Host "Delegating SPN for the Blueprint Assignment '$($response.identity.principalId)' as owner of subscription $sub"
    Add-AzRBACRole -subscriptionID $sub -roleDefinitionId $roleDefinitionId -spn $response.identity.principalId
  }
  
  return $response
}


function Get-BlueprintAssignments {
  param(
    [string]$subscriptionID,
    [string]$assignmentName
  )

  $restUri = "https://management.azure.com/subscriptions/$subscriptionID/providers/Microsoft.Blueprint/blueprintAssignments/"+$assignmentName+"?api-version=2018-11-01-preview"

  $response = Invoke-RestMethod -Uri $restUri -Method GET -Headers (Get-azToken)
  return $response
}


function Get-PolicyEvaluation {
  param(
    [string]$subscriptionID,
    [string]$assignmentName
  )

  $restUri = "https://management.azure.com/subscriptions/$subscriptionId/providers/Microsoft.PolicyInsights/policyStates/latest/triggerEvaluation?api-version=2018-07-01-preview"
  
  $response = Invoke-RestMethod -Uri $restUri -Method GET -Headers (Get-azToken)
  return $response
}
