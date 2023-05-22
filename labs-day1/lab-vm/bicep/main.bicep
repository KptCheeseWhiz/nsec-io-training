@description('Name of Resource Group that will be created. Defaults to a predefined value')
param resourceGroupName string = ''

@description('Id of the Subscription the Resources will be provisioned within (e.g.: 41a43949-ccc4-4d0d-b2f6-a073dcfb61da)')
param subscriptionId string = ''

@description('Name of the region where the resources are deployed. (e.g.: westeurope)')
param location string = ''

param adminUsername string = 'nsecadmusr'

param vmName string = 'nsecvm1'

@description('Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string

module vm './modules/vm.bicep' = {
  scope: resourceGroup(subscriptionId, resourceGroupName)
  name: 'vmDeployment'
  params: {
    location: location
    vmName: vmName
    adminUsername: adminUsername
    adminPassword: adminPassword
  }
}

/*
module cse 'modules/cse.bicep' = {
  name: 'cseDeployment'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    vmName: vmName
    location: location
  }
  dependsOn: [
    vm
  ]
}
*/
