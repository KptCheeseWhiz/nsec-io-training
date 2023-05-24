targetScope = 'subscription'

param logDiagnosticsSubscriptionName string = 'nsec-diag-sub'
param resourceGroupName string = ''
param lawName string = ''

resource lawResource 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: lawName
  scope: resourceGroup(resourceGroupName)
}
resource subscriptionActivityLog 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: logDiagnosticsSubscriptionName
  properties: {
    workspaceId: lawResource.id
    logs: [
      {
        category: 'Administrative'
        enabled: true
      }
      { 
        category: 'Security'
        enabled: true
      }
      {
        category: 'Alert'
        enabled: true
      }
      {
        category: 'Policy'
        enabled: true
      }
    ]
  }
}
