param lawName string = 'nsec-law-1'
param location string = ''
param retentionInDays int = 30

resource lawResource 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: lawName
  location: location
  properties: {
    retentionInDays: retentionInDays
  }
}

output lawResource object = lawResource.properties
