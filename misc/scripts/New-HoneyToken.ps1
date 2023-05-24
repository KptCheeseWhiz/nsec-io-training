function New-HoneyToken {

    <#
    Author: Karim El-Melhaoui
    Description: 
    1. Creates a new Service Principal in Azure AD with no permissions.
    2. Creates a Key Vault with name based on Resource Group + kv + 4 random chars
    3. Adds Diagnostic Logging to the Key Vault. Note that the Resource URI for the Log Analytics Workspace must be required.
    Purpose:
    Creates a simple honey token that can be monitored for logon attempts. 
    Note: AAD Logs is required to detect sign-ins with the service principal. 
    #>


    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = "Name of the Resource Group.")]
        [string]$ResourceGroupName,
        [Parameter(Mandatory = $true,
            HelpMessage = "Id of the subscription.")]
        [string]$SubscriptionId,
        [Parameter(Mandatory = $false,
        HelpMessage = "Enable Diagnostic Logging true/false")]
        [switch]$EnableDiagnosticLogging,
        [Parameter(Mandatory = $false,
        HelpMessage = "Workspace Id for the Log Analytics Workspace.")]
        [string]$WorkspaceId
    )
    $sp = New-AzADServicePrincipal -DisplayName ServicePrincipalName
    $honeyTokenClear = $sp.PasswordCredentials.SecretText
    $honeyToken =  ConvertTo-SecureString $honeyTokenClear -AsPlainText -Force
    $tokenName = $sp.AppId

    Write-Output  'Adding Service Principal..' $sp

    $Location = (Get-AzResourceGroup -Name $ResourceGroupName).Location
        
    $rand = -join ((48..57) + (97..122) | Get-Random -Count 4 | ForEach-Object { [char]$_ }) 
    $vaultName = $ResourceGroupName + '-kv-' + $rand
    $kv = New-AzKeyVault -Name $vaultName -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName  -EnablePurgeProtection -Location $Location

    $secret = Set-AzKeyVaultSecret -VaultName $vaultName -Name $tokenName -SecretValue $honeyToken
    Write-Output 'Successfully created secret:' $secret

    if ($EnableDiagnosticLogging.IsPresent) {

        Write-Output "Enabling Log Analytics for Key Vault.."
        $kv.ResourceId
        $WorkspaceId

        #Create a authorization header for interacting with REST API
        $Token = Get-AzAccessToken
        $Headers = @{Authorization = "Bearer $($Token.Token)" }
        
        $data = @{
            properties =  @{
            workspaceId = "$workspaceId";
        }
        };
        $json = $data | ConvertTo-Json

        Invoke-RestMethod -Method Put -Uri "https://management.azure.com/$($kv.ResourceId)/providers/Microsoft.Insights/diagnosticSettings/kv-diag?api-version=2021-05-01-preview" -Headers $Headers -Body $json -ContentType "application/json"
        
    }
}