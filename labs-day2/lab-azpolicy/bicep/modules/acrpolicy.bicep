param policyAssignmentName string
param policyDefinitionID string

param policyEffect string

//param subscriptionId string

targetScope = 'subscription'

resource assignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
    name: policyAssignmentName
    properties: {
        policyDefinitionId: policyDefinitionID
        parameters: {
            effect: {
                value: policyEffect
            }
        }
    }
}

output assignmentId string = assignment.id
