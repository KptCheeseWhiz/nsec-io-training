@description('Username for the Virtual Machine.')
param adminUsername string = 'nsecadmusr'

@description('Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string

@description('Unique DNS Name for the Public IP used to access the Virtual Machine.')
param dnsLabelPrefix string = toLower('${vmName}-${uniqueString(resourceGroup().id, vmName)}')

@description('Name for the Public IP used to access the Virtual Machine.')
param publicIpName string = 'nsecpip'

@description('Allocation method for the Public IP used to access the Virtual Machine.')
param publicIPAllocationMethod string = 'Dynamic'

@description('SKU for the Public IP used to access the Virtual Machine.')
param publicIpSku string = 'Basic'

@description('The Windows version for the VM. This will pick a fully patched image of this given Windows version.')
param OSVersion string = '2022-datacenter-azure-edition'

@description('Size of the virtual machine.')
param vmSize string = 'Standard_D2s_v5'

@description('Location for all resources.')
param location string = resourceGroup().location

param vmName string = ''

var nicName = 'nsecNIC'
var addressPrefix = '10.0.0.0/16'
var subnetName = 'Subnet'
var subnetPrefix = '10.0.0.0/24'
var virtualNetworkName = 'Nsec-VNET'
var networkSecurityGroupName = 'default-NSG'

resource publicIp 'Microsoft.Network/publicIPAddresses@2022-05-01' = {
  name: publicIpName
  location: location
  sku: {
    name: publicIpSku
  }
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2022-05-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-3389'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '3389'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2022-05-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIp.id
          }
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
          }
        }
      }
    ]
  }
  dependsOn: [
    virtualNetwork
  ]
}

resource vm 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: vmName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    userData: 'IDwjCi5TWU5PUFNJUwogICAgRnVuY3Rpb24gZm9yIGRvd25sb2FkaW5nIGFuZCBleGVjdXRpbmcgSGFyZGVuaW5nS2l0dHkKICAgIGh0dHBzOi8vZ2l0aHViLmNvbS9zY2lwYWcvSGFyZGVuaW5nS2l0dHkKCi5ERVNDUklQVElPTgogICAgVHJpZ2dlcnMgdGhyZWUgZGlzdGluY3RpdmUgZnVuY3Rpb25zIGFzIGEgc2luZ2xlIGxpbmUgdG8gYXBwbHkgaGFyZGVuaW5nIGFuZCBwYXNzaW5nIHRoZSBwYXJhbWV0ZXJzLgogICAgCi5QQVJBTUVURVIgRmlsZUZpbmRpbmdMaXN0CiAgICBUaGUgcGF0aCB0byB0aGUgQ1NWIGZpbGUgZm9yIEhhcmRlbmluZ0tpdHR5IGNvbmZpZ3VyYXRpb24uCgouUEFSQU1FVEVSIEhhcmRlbmluZ0tpdHR5UGF0aAogICAgVGhlIHBhdGggdG8gd2hlcmUgSGFyZGVuaW5nS2l0dHkgbW9kdWxlIGlzIGltcG9ydGVkIGZyb20uCgouUEFSQU1FVEVSIFVuemlwUGF0aAogICAgVGhlIHBhdGggdG8gd2hlcmUgdGhlIGRvd25sb2FkZWQgZmlsZSBpcyB1bnppcHBlZCB0by4KCi5QQVJBTUVURVIgUGFja2FnZVVybAogICAgVGhlIFVSTCB0byB0aGUgemlwIHBhY2thZ2UgdG8gZG93bmxvYWQgYW5kIGV4dHJhY3QuCgouTk9URVMKICAgIEFsbCBwYXJhbWV0ZXJzIGFyZSBwYXNzZWQgaW4gdGhlIHN1cGVyLWZ1bmN0aW9uIHRvIHRoZSBjb3JyZXNwb25kaW5nIGZ1bmN0aW9ucy4gCgouRVhBTVBMRSAKICAgIEludm9rZS1IYXJkZW5pbmcKICAgIEludm9rZS1IYXJkZW5pbmcgLUZpbGVGaW5kaW5nTGlzdCA8cGF0aCB0byBjdXN0b20gZmlsZSBmaW5kaW5nIGxpc3Q+CiM+CgpmdW5jdGlvbiBJbnZva2UtSGFyZGVuaW5nIHsKICAgIFtDbWRsZXRCaW5kaW5nKCldCiAgICBwYXJhbSAoCiAgICAgICAgW1BhcmFtZXRlcihNYW5kYXRvcnkgPSAkZmFsc2UpXQogICAgICAgIFtzdHJpbmddCiAgICAgICAgJEZpbGVGaW5kaW5nTGlzdCA9IChKb2luLVBhdGggLVBhdGggJGVudjpURU1QIC1DaGlsZFBhdGggIlNlY3VyaXR5QmFzZWxpbmVcSGFyZGVuaW5nS2l0dHktdi4wLjkuMFxsaXN0c1xmaW5kaW5nX2xpc3RfMHg2ZDY5NjM2Yl9tYWNoaW5lLmNzdiIpLAogICAgICAgIFtzdHJpbmddCiAgICAgICAgJEhhcmRlbmluZ0tpdHR5UGF0aCA9ICggSm9pbi1QYXRoICRlbnY6VEVNUCAtQ2hpbGRQYXRoICJTZWN1cml0eUJhc2VsaW5lXEhhcmRlbmluZ0tpdHR5LXYuMC45LjAiICksCiAgICAgICAgW1BhcmFtZXRlcihNYW5kYXRvcnkgPSAkZmFsc2UpXQogICAgICAgIFtzdHJpbmddCiAgICAgICAgJFVuemlwUGF0aCA9ICggSm9pbi1QYXRoICRlbnY6VEVNUCAtQ2hpbGRQYXRoICJTZWN1cml0eUJhc2VsaW5lIiApLAogICAgICAgIFtQYXJhbWV0ZXIoTWFuZGF0b3J5ID0gJGZhbHNlKV0KICAgICAgICBbc3RyaW5nXQogICAgICAgICRQYWNrYWdlVXJsID0gImh0dHBzOi8vZ2l0aHViLmNvbS9zY2lwYWcvSGFyZGVuaW5nS2l0dHkvYXJjaGl2ZS9yZWZzL3RhZ3Mvdi4wLjkuMC56aXAiCiAgICApCgogICAgZnVuY3Rpb24gR2V0LVVuemlwcGVkUGFja2FnZSB7CiAgICAgICAgcGFyYW0oCiAgICAgICAgICAgIFtQYXJhbWV0ZXIoTWFuZGF0b3J5ID0gJHRydWUpXQogICAgICAgICAgICBbc3RyaW5nXQogICAgICAgICAgICAkUGFja2FnZVVybCwKICAgICAgICAgICAgW1BhcmFtZXRlcihNYW5kYXRvcnkgPSAkdHJ1ZSldCiAgICAgICAgICAgIFtzdHJpbmddCiAgICAgICAgICAgICRVbnppcFBhdGgKICAgICAgICApCiAgICAgICAgdHJ5IHsKCiAgICAgICAgICAgIFdyaXRlLUluZm9ybWF0aW9uIC1NZXNzYWdlRGF0YSAiRG93bmxvYWRpbmcgdGhlIHppcCBwYWNrYWdlIGZyb20gdGhlICRQYWNrYWdlVXJsIgogICAgICAgICAgICAkcGFja2FnZSA9IEludm9rZS1XZWJSZXF1ZXN0ICRQYWNrYWdlVXJsIC1Vc2VCYXNpY1BhcnNpbmcKCiAgICAgICAgICAgIFdyaXRlLUluZm9ybWF0aW9uIC1NZXNzYWdlRGF0YSAiQ3JlYXRpbmcgYSBuZXcgdGVtcG9yYXJ5IGRpcmVjdG9yeSIKICAgICAgICAgICAgJHRlbXBEaXIgPSBOZXctSXRlbSAtSXRlbVR5cGUgRGlyZWN0b3J5IC1QYXRoIChKb2luLVBhdGggJGVudjpURU1QIChbU3lzdGVtLkd1aWRdOjpOZXdHdWlkKCkuVG9TdHJpbmcoKSkpCgogICAgICAgICAgICBXcml0ZS1JbmZvcm1hdGlvbiAtTWVzc2FnZURhdGEgIlNhdmluZyB0aGUgcGFja2FnZSBjb250ZW50IHRvIGEgdGVtcG9yYXJ5IGZpbGUiCiAgICAgICAgICAgICR0ZW1wRmlsZSA9IEpvaW4tUGF0aCAkdGVtcERpci5GdWxsTmFtZSAicGFja2FnZS56aXAiCiAgICAgICAgICAgIFtJTy5GaWxlXTo6V3JpdGVBbGxCeXRlcygkdGVtcEZpbGUsICRwYWNrYWdlLkNvbnRlbnQpCiAgICAgICAgCiAgICAgICAgICAgIFdyaXRlLUluZm9ybWF0aW9uIC1NZXNzYWdlRGF0YSAiRXh0cmFjdGluZyB0aGUgY29udGVudHMgb2YgdGhlIHppcCBmaWxlIHRvIHRoZSBkZXN0aW5hdGlvbiBkaXJlY3RvcnkiCiAgICAgICAgICAgIEV4cGFuZC1BcmNoaXZlIC1QYXRoICR0ZW1wRmlsZSAtRGVzdGluYXRpb25QYXRoICRVbnppcFBhdGggLUZvcmNlCgogICAgICAgICAgICBXcml0ZS1JbmZvcm1hdGlvbiAtTWVzc2FnZURhdGEgIlJlbW92aW5nIHRoZSB0ZW1wb3JhcnkgZGlyZWN0b3J5IGFuZCBpdHMgY29udGVudHMiCiAgICAgICAgICAgIFJlbW92ZS1JdGVtICR0ZW1wRGlyLkZ1bGxOYW1lIC1SZWN1cnNlIC1Gb3JjZQogICAgICAgIH0KICAgICAgICBjYXRjaCB7CiAgICAgICAgICAgIFdyaXRlLUVycm9yIC1NZXNzYWdlICJGYWlsZWQgdG8gZG93bmxvYWQgYW5kIHVuemlwIHBhY2thZ2UgZnJvbSAkVXJsLiAkXyIKICAgICAgICB9CiAgICB9CgogICAgZnVuY3Rpb24gSW52b2tlLUhhcmRlbmluZ0tpdHR5SGVscGVyIHsKICAgICAgICBbQ21kbGV0QmluZGluZygpXQogICAgICAgIHBhcmFtICgKICAgICAgICAgICAgW1BhcmFtZXRlcihNYW5kYXRvcnkgPSAkdHJ1ZSldCiAgICAgICAgICAgIFtzdHJpbmddCiAgICAgICAgICAgICRGaWxlRmluZGluZ0xpc3QsCiAgICAgICAgICAgIFtQYXJhbWV0ZXIoTWFuZGF0b3J5ID0gJHRydWUpXQogICAgICAgICAgICBbc3RyaW5nXQogICAgICAgICAgICAkSGFyZGVuaW5nS2l0dHlQYXRoCiAgICAgICAgKQogICAgICAgIHRyeSB7CiAgICAgICAgICAgIFdyaXRlLUluZm9ybWF0aW9uIC1NZXNzYWdlRGF0YSAiSW1wb3J0aW5nIHRoZSBIYXJkZW5pbmdLaXR0eSBtb2R1bGUiCiAgICAgICAgICAgIEltcG9ydC1Nb2R1bGUgLU5hbWUgKEpvaW4tUGF0aCAtUGF0aCAkSGFyZGVuaW5nS2l0dHlQYXRoIC1DaGlsZFBhdGggIkhhcmRlbmluZ0tpdHR5LnBzbTEiKSAtRXJyb3JBY3Rpb24gU3RvcAogICAgICAgIH0KICAgICAgICBjYXRjaCB7CiAgICAgICAgICAgIFdyaXRlLUVycm9yIC1NZXNzYWdlICJGYWlsZWQgdG8gaW1wb3J0IG1vZHVsZSBmcm9tICRIYXJkZW5pbmdLaXR0eVBhdGguICRfIgogICAgICAgICAgICByZXR1cm4KICAgICAgICB9CiAgICAKICAgICAgICB0cnkgewogICAgICAgICAgICBXcml0ZS1JbmZvcm1hdGlvbiAtTWVzc2FnZURhdGEgIkludm9raW5nIHRoZSBIYXJkZW5pbmdLaXR0eSBzY3JpcHQgd2l0aCB0aGUgRmlsZUZpbmRpbmdMaXN0IHByb3ZpZGVkIgogICAgICAgICAgICBJbnZva2UtSGFyZGVuaW5nS2l0dHkgLUZpbGVGaW5kaW5nTGlzdCAkRmlsZUZpbmRpbmdMaXN0IC1Nb2RlIEhhaWxNYXJ5IC1Mb2cgLVJlcG9ydCAtU2tpcFJlc3RvcmVQb2ludAogICAgICAgIH0KICAgICAgICBjYXRjaCB7CiAgICAgICAgICAgIFdyaXRlLUVycm9yIC1NZXNzYWdlICJGYWlsZWQgdG8gcnVuIEludm9rZS1IYXJkZW5pbmdLaXR0eS4gJF8iCiAgICAgICAgfQogICAgfQoKICAgICRHZXRVbnppcHBlZFBhY2thZ2VQYXJhbXMgPSBAeyAKICAgICAgICBQYWNrYWdlVXJsID0gJFBhY2thZ2VVcmwgCiAgICAgICAgVW56aXBQYXRoICA9ICRVbnppcFBhdGgKICAgIH0KICAgIEdldC1VbnppcHBlZFBhY2thZ2UgQEdldFVuemlwcGVkUGFja2FnZVBhcmFtcwoKICAgICRJbnZva2VIYXJkZW5pbmdLaXR0eUhlbHBlclBhcmFtcyA9IEB7CiAgICAgICAgRmlsZUZpbmRpbmdMaXN0ICAgID0gJEZpbGVGaW5kaW5nTGlzdCAKICAgICAgICBIYXJkZW5pbmdLaXR0eVBhdGggPSAkSGFyZGVuaW5nS2l0dHlQYXRoCiAgICB9CiAgICBJbnZva2UtSGFyZGVuaW5nS2l0dHlIZWxwZXIgQEludm9rZUhhcmRlbmluZ0tpdHR5SGVscGVyUGFyYW1zCn0KCkludm9rZS1IYXJkZW5pbmcgCg=='
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: OSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

output hostname string = publicIp.properties.dnsSettings.fqdn
output principalId string = vm.identity.principalId
