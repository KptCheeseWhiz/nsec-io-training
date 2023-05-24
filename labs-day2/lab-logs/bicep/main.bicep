targetScope = 'subscription'

@description('Sets the time now to concatenate the string in the deployment name with a unqiue value.')
param dateTime string = utcNow()

@description('Name of Resource Group that will be created. Defaults to a predefined value')
param resourceGroupName string = ''

@description('Id of the Subscription the Resources will be provisioned within (e.g.: 41a43949-ccc4-4d0d-b2f6-a073dcfb61da)')
param subscriptionId string = ''

@description('Name of the region where the resources are deployed. (e.g.: westeurope)')
param location string = ''

param lawName string = 'nsec-law-1'

param logDiagnosticsSubscriptionName string = 'nsec-diag-sub'

module law './modules/law.bicep' = {
  scope: resourceGroup(subscriptionId, resourceGroupName)
  name: 'lawDeployment-${dateTime}'
  params: {
    location: location
    lawName: lawName
  }
  dependsOn: [
  ]
}


module diagSub './modules/diagSub.bicep' = {
  name: 'diagSubDeploy-${dateTime}'
  params: {
    lawName: lawName
    logDiagnosticsSubscriptionName: logDiagnosticsSubscriptionName
    resourceGroupName: resourceGroupName
  }
  dependsOn: [
    law
  ]
}
