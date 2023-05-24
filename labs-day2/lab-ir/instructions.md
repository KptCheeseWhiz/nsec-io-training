## Lab Objective
In this lab we will download the tool "dumpit" to collect the instance volatile memory, we will then leverage the instances Managed Identity and Storage Account access to allow the instance to upload the memory dump file to an Azure Storage account.

## Instructions
1. Inspect the script "Invoke-MemoryCollection.ps1" and the different steps it has.
2. Ensure that the Managed Identity still has access to the storage account we created yesterday.
3. Update the script to provide the name of your storage account
4. Execute the function and pay attention to the actions.
5. Access the Storage account and you should find a copy of the instance memory.
