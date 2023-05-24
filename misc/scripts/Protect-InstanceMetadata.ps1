<#
.SYNOPSIS
    Protects the Instance Metadata Service using Windows Firewall
.DESCRIPTION
    Protects the Instance Metadata Service using Windows Firewall by limiting which principals are allowed to make calls to the local endpoint.
    Provide the ExceptionPrincipal with the name of the Prinicpal you want to restrict, by default it will restrict to "Administrators". 

    Author: Karim El-Melhaoui, O3 Cyber
.NOTES
    This function is only supported on Windows and requires Windows Firewall to be enabled.
#>

function Protect-InstanceMetadata {
    param (
        [Parameter(Mandatory = $false)]
        [string]
        $ExceptionPrincipal = (New-Object -TypeName System.Security.Principal.NTAccount ("Administrators"))
    )
    

$BlockPrincipal = New-Object -TypeName System.Security.Principal.NTAccount ("Everyone")
$BlockPrincipalSID = $blockPrincipal.Translate([System.Security.Principal.SecurityIdentifier]).Value
$ExceptionPrincipal = New-Object -TypeName System.Security.Principal.NTAccount ("Administrators")
$ExceptionPrincipalSID = $exceptionPrincipal.Translate([System.Security.Principal.SecurityIdentifier]).Value
$PrinicipalSecurityDescriptor = "O:LSD:(D;;CC;;;$ExceptionPrincipalSID)(A;;CC;;;$BlockPrincipalSID)"

New-NetFirewallRule -DisplayName "Block metatdata service for $($blockPrincipal.Value), exception: $($exceptionPrincipal.Value)" `
    -Action Block `
    -Direction Outbound `
    -Protocol TCP `
    -RemoteAddress 169.254.169.254 `
    -LocalUser $PrinicipalSecurityDescriptor
    
}
