## Hints
2. The PublicNetworkAccess is set to its default value, which corresponds with "Enabled".
3. To allow ACR to disable publicNetworkAccess for an ACR, you also need to change the SKU. 
4. az deployment sub create --location eastus --template-file labs-day2/lab-azpolicy/bicep/main.bicep --parameters ./labs-day2/parameters/main.parameters.json --name acrdeployment