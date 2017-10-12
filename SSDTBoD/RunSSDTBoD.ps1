Clear-Host
Import-Module  ".\SSDTBoD" -Force
Test-DatabaseEngineInstalled
$MSBuildInstaller = Join-Path $PSScriptRoot "BuildTools_Full.exe"
$MSBuildInstallArgs = {$MSBuildInstaller + " /qn"}
$MSBuildPath = "C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe"
if (-not (Test-Path $MSBuildPath)) {
    Write-Warning "no msbuild. Am attempting to install."
    Invoke-Command -ScriptBlock $MSBuildInstallArgs
}
$WWI_OLTP_NAME = "WideWorldImporters"
$WWI_DW_NAME = "WideWorldImportersDW"

$WWI_DW = Join-Path (Split-Path -Path $PSScriptRoot -Parent) "\WWI_DW_SSDT\wwi-dw-ssdt"
$WWI_OLTP = Join-Path (Split-Path -Path $PSScriptRoot -Parent) "\WWI_SSDT\wwi-ssdt"

$WWI_OLTP_SLN = Join-Path $WWI_OLTP "\WideWorldImporters.sqlproj"
$WWI_DW_SLN = Join-Path $WWI_DW "\WideWorldImportersDW.sqlproj"

$WWI_OLTP_DAC = Join-Path $WWI_OLTP "\Microsoft.Data.Tools.Msbuild\lib\net46"
$WWI_DW_DAC = Join-Path $WWI_DW "\Microsoft.Data.Tools.Msbuild\lib\net46"

$WWI_OLTP_DACFX = Join-Path $WWI_OLTP_DAC "\Microsoft.SqlServer.Dac.dll"
$WWI_DW_DACFX = Join-Path $WWI_DW_DAC "\Microsoft.SqlServer.Dac.dll"

$WWI_OLTP_DACPAC = Join-Path $WWI_OLTP "\bin\Debug\WideWorldImporters.dacpac"
$WWI_DW_DACPAC = Join-Path $WWI_DW "\bin\Debug\WideWorldImportersDW.dacpac"

$WWI_OLTP_PUB = Join-Path $WWI_OLTP "\bin\Debug\WideWorldImporters.publish.xml"
$WWI_DW_PUB = Join-Path $WWI_DW "\bin\Debug\WideWorldImportersDW.publish.xml"

$InstanceUnderUse = "SERVER=.;Integrated Security=True;Database=master"

Install-MicrosoftDataToolsMSBuild -WorkingFolder $WWI_OLTP -NugetPath $PSScriptRoot
Install-MicrosoftDataToolsMSBuild -WorkingFolder $WWI_DW -NugetPath $PSScriptRoot

Invoke-MsBuildSSDT -DatabaseSolutionFilePath $WWI_OLTP_SLN -DataToolsFilePath $WWI_OLTP_DAC 
Invoke-MsBuildSSDT -DatabaseSolutionFilePath $WWI_DW_SLN -DataToolsFilePath $WWI_DW_DAC 

Publish-DatabaseDeployment -dacfxPath $WWI_OLTP_DACFX -dacpac $WWI_OLTP_DACPAC -publishXml $WWI_OLTP_PUB -targetConnectionString $InstanceUnderUse -targetDatabaseName $WWI_OLTP_NAME
Publish-DatabaseDeployment -dacfxPath $WWI_DW_DACFX -dacpac $WWI_DW_DACPAC -publishXml $WWI_DW_PUB -targetConnectionString $InstanceUnderUse -targetDatabaseName $WWI_DW_NAME

Publish-SysAdminUser -SqlConnectionString $InstanceUnderUse