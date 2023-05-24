@description('Name of the region where the resources are deployed. (e.g.: westeurope)')
param location string

@description('Sets the time now to concatenate the string in the deployment name with a unqiue value.')
param dateTime string = utcNow()

module storacc 'modules/storacc.bicep' = {
  name: 'storaccDeployment-${dateTime}'
  params: {
    location: location
  }
}


param vmName string = 'nsecvm1'
param roleDefinitionId string = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'

resource vm 'Microsoft.Compute/virtualMachines@2022-11-01' existing = {
  name: vmName
}

module roleAssignment 'modules/roleassignment.bicep' = {
  name: 'role-assignment-${dateTime}'
  params: {
    storAccName: storacc.outputs.storAccName
    location: location
    principalId: vm.identity.principalId
    roleDefinitionId: roleDefinitionId
  }
  dependsOn: [
    storacc
  ]
}
