targetScope = 'subscription'

@description('Sets the time now to concatenate the string in the deployment name with a unqiue value.')
param dateTime string = utcNow()

@description('Name of Resource Group that will be created. Defaults to a predefined value')
param resourceGroupName string

@description('Name of the region where the resources are deployed. (e.g.: westeurope)')
param location string

@description('Id of the Subscription the Resources will be provisioned within (e.g.: 41a43949-ccc4-4d0d-b2f6-a073dcfb61da)')
param subscriptionId string

param acrName string = 'nsecioacr'
param acrSku string = 'Standard'
param publicNetworkAccess string = 'Enabled'


module acr './modules/acr.bicep' = {
  name: 'resourceGroupDeployment-${dateTime}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    publicNetworkAccess: publicNetworkAccess
    acrName: acrName
    acrSku: acrSku
    location: location
  }/*
  dependsOn: [
    acrPolicy
  ]*/
}

/*
param policyAssignmentName string = 'container-registries-disable-public'
param policyDefinitionID string = '/providers/Microsoft.Authorization/policyDefinitions/0fdf0491-d080-4575-b627-ad0e843cba0f'
param policyEffect string = 'Deny'

module acrPolicy './modules/acrpolicy.bicep' = {
  scope: subscription(subscriptionId)
  name: 'acrPolicy-${dateTime}'
  params: {
    policyEffect: policyEffect
    policyDefinitionID: policyDefinitionID
    policyAssignmentName: policyAssignmentName
  }
}
*/
