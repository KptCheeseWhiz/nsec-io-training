param vmName string = ''
param location string = ''

resource configAppExtension 'Microsoft.Compute/virtualMachines/extensions@2022-11-01' = {

  name: '${vmName}/InvokeHardening'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      managedIdentity: {}
      fileUris: [
        'https://gist.githubusercontent.com/karimelmel/9897d373502ccaed22ac3722aa13b878/raw/a68bc0d8dbad022980857106d0df8eaf64e561e6/Invoke-Hardening.ps1'
      ]
      commandToExecute: 'powershell.exe -ExecutionPolicy Bypass -File Invoke-Hardening.ps1'
    }
  }
}
