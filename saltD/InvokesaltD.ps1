param (
    [String]$InstanceUnderUse,
    [String]$MachineOrDomainName,
    [String]$userName,
    [String]$Password,
    [String]$SQLAgentServerName,
    [String]$IntegrationServicesCatalogServer,
    [string]$LocalModulePath

)
Function Invoke-saltD {
    Import-Module  ".\saltD" -Force
    $WWI_SSIS = Join-Path (Split-Path -Path $PSScriptRoot -Parent) "\WWI_SSIS"
    $WWI_SSIS_XML = Join-Path $WWI_SSIS "RunDailyETL.xml"
    if (!$LocalModulePath) {
        Write-Host "Installing salt from Nuget" -ForegroundColor White -BackgroundColor DarkMagenta
        Install-salt -WorkingFolder $PSScriptRoot -NugetPath $PSScriptRoot 
        Import-Module "$PSScriptRoot\salt" -Force
    }
    else {
        if (Test-Path $LocalModulePath) {
            Write-Host "Installing salt from supplied path $localModulePath" -ForegroundColor White -BackgroundColor DarkMagenta
            Import-Module $LocalModulePath -Force
        }
        else {
            Write-Error "Local Module of salt not found at path supplied."
            Throw
        }
    }
    Invoke-Salt -JobManifestXmlFile $WWI_SSIS_XML -connection_string $InstanceUnderUse -MachineOrDomainName $MachineOrDomainName -userName $userName -password $Password
}
Invoke-saltD


