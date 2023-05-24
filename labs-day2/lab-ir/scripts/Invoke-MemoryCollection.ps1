<#
.SYNOPSIS
    A super-function to Invoke-MemoryCollection process for forensic memory on Azure Virtual Machinesd.

.DESCRIPTION
    Triggers three distinctive functions as a single line to download required prerequisities and unzip the package, run the executable to acquire volatile memory and then upload the data to an Azure Storage Account.
    
.NOTES
    All parameters should be passed in a super-function to the corresponding functions. 
.EXAMPLE 
#>

function Invoke-MemoryCollection {
    [CmdLetBinding()]
    param ( 
        [Parameter(Mandatory = $false)]
        [string]
        $PackageUrl = "https://storage.googleapis.com/prod-releases/comae_toolkit/Comae-Toolkit-v20230117.zip",
        [Parameter(Mandatory = $false)]
        [string]
        $UnzipPath = ( Join-Path $env:TEMP -ChildPath "MemoryToolkit" ),
        [Parameter(Mandatory = $false)]
        [string]
        $DumpItExecuteable = (Join-Path $env:TEMP -ChildPath "MemoryToolkit\x64\DumpIt.exe" ),
        [Parameter(Mandatory = $false)]
        [string]
        $MemoryFile = (Join-Path -Path $env:TEMP -ChildPath mem.dmp),
        [Parameter(Mandatory = $false)]
        [string]
        $StorageAccountName = 'INSERT',
        [Parameter(Mandatory = $false)]
        [string]
        $ContainerName = 'artifacts',
        [Parameter(Mandatory = $false)]
        [string]
        $LocalFilePath = $MemoryFile
    )

    function Get-UnzippedPackage {
        param(
            [Parameter(Mandatory = $false)]
            [string]
            $PackageUrl,
            [Parameter(Mandatory = $false)]
            [string]
            $UnzipPath
        )
    
        try {
            Write-Information -MessageData "Downloading the zip package from the $PackageUrl"
            $package = Invoke-WebRequest $PackageUrl -UseBasicParsing

            Write-Information -MessageData "Creating a new temporary directory"
            $tempDir = New-Item -ItemType Directory -Path (Join-Path $env:TEMP ([System.Guid]::NewGuid().ToString()))

            Write-Information -MessageData "Saving the package content to a temporary file"
            $tempFile = Join-Path $tempDir.FullName "package.zip"
            [IO.File]::WriteAllBytes($tempFile, $package.Content)
    
            Write-Information -MessageData "Extracting the contents of the zip file to the destination directory"
            Expand-Archive -Path $tempFile -DestinationPath $UnzipPath -Force

            Write-Information -MessageData "Removing the temporary directory and its contents"
            Remove-Item $tempDir.FullName -Recurse -Force
        }
        catch {
            Write-Error -Message "Failed to download and unzip package from $Url. $_"
        }
    }

    function Start-MemoryAcquisition {
        param(
            [Parameter(Mandatory = $false)]
            [string]
            $DumpItExecuteable,
            [Parameter(Mandatory = $false)]
            [string]
            $MemoryFile
        )

        try {
            Write-Information "Writing memory to file mem.dmp using DumpIt"
        (Test-Path $DumpItExecuteable)
            & $DumpItExecuteable /n /q /o $MemoryFile
        }
        catch {
            Write-Error -Message "Failed to initialize DumpIt $_"
        }
    }


    function Export-DataToAzureStorage {
        param (
            [Parameter(Mandatory = $true)]
            [string]$StorageAccountName,
            [Parameter(Mandatory = $true)]
            [string]$ContainerName,
            [Parameter(Mandatory = $true)]
            [string]$LocalFilePath
        )

        try {
            Write-Information  -MessageData "Getting the managed identity token from the instance metadata endpoint"
            $tokenEndpoint = "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://storage.azure.com/"
            $managedIdentityToken = Invoke-RestMethod -Uri $tokenEndpoint -Headers @{Metadata = "true" } | Select-Object -ExpandProperty access_token

            # Set the Blob Storage REST API URL for the blob
            $blobUri = "https://$StorageAccountName.blob.core.windows.net/$ContainerName/$(Split-Path $LocalFilePath -Leaf)"

            # Set the headers for the REST API call
            $headers = @{
                "Authorization" = "Bearer $managedIdentityToken"
                "x-ms-version"  = "2019-12-12"
            }

            Write-Information -MessageData "Uploading the memory file using Invoke-WebRequest: $blobName"
            # 
            Invoke-WebRequest -Uri $blobUri -Method Put -InFile $LocalFilePath -Headers $headers
        }
        catch {
            Write-Error -Message "Failed to import Azure Blob artifacts. $_"
        }
    }

    $GetUnzippedPackagedParams = @{
        PackageUrl = $PackageUrl
        UnzipPath  = $UnzipPath
    } 
    Get-UnzippedPackage @GetUnzippedPackagedParams

    $StartMemoryAcquisitionParams = @{
        DumpItExecuteable = $DumpItExecuteable
        MemoryFile        = $MemoryFile
    }
    Start-MemoryAcquisition @StartMemoryAcquisitionParams


    $ExportDataToAzureStorageParams = @{
        StorageAccountName = $StorageAccountName
        ContainerName      = $ContainerName
        LocalFilePath      = $LocalFilePath
    }
    Export-DataToAzureStorage @ExportDataToAzureStorageParams

}

Invoke-MemoryCollection