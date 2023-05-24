## Lab objective
Our Organization is preparing for using containers and want to leverage Azure Container Registry for storing container images. It is important that all container images are private to the organization.

In this lab we will investigate the Bicep template for deploying Azure Container Registry and learn the risk associated with some of its default settings. We will simultaneously deploy an Azure Policy to prevent risky settings in our workspace and see how that policy takes effect.


## Instructions
1. Inspect the main.bicep file and consider what resources are being deployed. Notice the configuration settings for the ACR. 
2. Have a look at the Policy we are about to deploy and inspect its content, it can be found here: https://www.azadvertizer.net/azpolicyadvertizer/0fdf0491-d080-4575-b627-ad0e843cba0f.html 
3. Notice the Azure Policy refers to a built-in definition and what parameters are being injected into the definiton file. 
4. Deploy the resources and make note of the error you receive.
5. Amend the resources to make them deployable without modifying the policy, as allowing a public ACR is unacceptable.
