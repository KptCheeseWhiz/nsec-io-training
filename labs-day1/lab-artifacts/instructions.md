## Lab objective
In this lab we will investigate how we can create a secure storage artifact repository, for either virtual machines to access tools that are helpful for incident response and for us to upload forensic evidence, without requiring an Access Key

## Instructions
1. Deploy the bicep template with the storage account
2. Inspect the permissions of the storage account
3. Consider how we can grant access to the virtual machine for the storage account without requiring to store secrets in clear-text
4. Remove the comments from the roleassignment module and attempt deployment, inspect the permissions on the storage account