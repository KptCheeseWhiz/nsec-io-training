## Lab objective
In this lab we will deploy our virtual machine, where we will familiarize with the different options for configuring a Virtual Machine with security hardening. We will test out deploying a script thrugh Userdata and then execute it from the host. 

Remember that scripts provided through UserData must be Base64 encoded.

## Instructions
1. Inspect the main.bicep file, notice the Bicep module that is being used. Analyze the Invoke-Hardening.ps1 script.
2. Add User Data to the Virtual Machine.  Note that it must be applied in base64. You can base64 encode the script using https://www.base64encode.org/
3. Log on to the Virtual Machine and confirm that the script is uploaded to the metadata endpoint.
4. Try to decode and execute the script.
5. Have a look in the main.bicep file and the escaped cse mdule that is being referenced. Read more about CSE here to understand further details: https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows
6. Try understanding the anatomy of the cse template and how that can be used to achieve the same. 
7. Uncomment the section and rerun the deployment, inspect the Virtual Machine and its Extensions to see the output of the script.
