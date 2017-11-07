param (
    $InstanceUnderUse,
    [switch]$build,
    [switch]$deploy,
    [string]$LocalModulePath,
    [Switch]$rollback,
    [Switch]$SimulateFailedDeployment,
    [Switch]$IncludePreRelease
)
Function Invoke-SSISBoD {
    Import-Module  ".\SSISBoD" -Force
    $WWI_SSIS = Join-Path (Split-Path -Path $PSScriptRoot -Parent) "\WWI_SSIS"
    $WWI_SSIS_SLN = Join-Path (Split-Path -Path $PSScriptRoot -Parent) "Assist_Deploy_WWI_SSIS_Samples.sln"
    $WWI_SSIS_PROJ = Join-Path $WWI_SSIS "WWI_SSIS.dtproj"
    $WWI_SSIS_JSON = Join-Path $WWI_SSIS "WWI_SSIS_ETL.json"
    $WWI_SSIS_ISPAC = Join-Path $WWI_SSIS "bin\development\WWI_SSIS.ispac"
    if ($build) {
        $devenv = 'C:\Program Files (x86)\Microsoft Visual Studio\2017\*\Common7\IDE\devenv.com'
        [boolean]$what = Test-VisualStudio2017Installed -vspath $devenv 
        if ($what -eq $true) {
            Write-Host "As Visual Studio 2017 is installed, we can build dtproj file." -ForegroundColor DarkMagenta
            Write-Host "If you want to open the project, you need to have at least SSDT 15.1 installed." -ForegroundColor Black -BackgroundColor Yellow
            Invoke-SsisBuild -vspath $devenv -ssis_proj $wwi_ssis_proj -ssis_sln $WWI_SSIS_SLN -config "Development"
        }
    }
    else {
        Write-Host "SSIS build skipped. Add build switch to run build." -ForegroundColor Black -BackgroundColor Red
    }
    if ($deploy) {
        Add-Type -Path 'C:\Program Files\Microsoft SQL Server\140\SDK\Assemblies\Microsoft.SqlServer.Smo.dll'
        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $InstanceUnderUse
        $SQLServer = New-Object Microsoft.SQLServer.Management.SMO.Server $sqlConnection
        $configuration = $SQLServer.Configuration
        $CLRValue = $SQLServer.Configuration.IsSqlClrEnabled
        Write-Host $CLRValue.ConfigValue
        if ($CLRValue.ConfigValue -eq 0) {
            Write-Host "Enabling CLR....."
            $CLRValue.ConfigValue = 1
            $configuration.Alter()
        }
        [Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Management.IntegrationServices") | Out-Null
        $CatalogPwd = "Password12345"
        $SSISCatalog = "SSISDB"
        $ISNamespace = "Microsoft.SqlServer.Management.IntegrationServices"
        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $InstanceUnderUse
        $integrationServices = New-Object "$ISNamespace.IntegrationServices" $sqlConnection
        $catalog = $integrationServices.Catalogs[$SSISCatalog]
        if (!$catalog) {
            Write-Host "Creating SSIS Catalog ..."
            $catalog = New-Object "$ISNamespace.Catalog" ($integrationServices, $SSISCatalog, $CatalogPwd)
            $catalog.Create()
        }
        else {
            Write-Host "Catalog $($catalog.Name) exists."
        }
        if (!$LocalModulePath) {
            Write-Host "Installing AssistDeploy from Nuget" -ForegroundColor White -BackgroundColor DarkMagenta
            if ($IncludePreRelease)
            {
                Install-AssistDeploy -WorkingFolder $PSScriptRoot -NugetPath $PSScriptRoot -IncludePreRelease
            }
            else {
                Install-AssistDeploy -WorkingFolder $PSScriptRoot -NugetPath $PSScriptRoot
            }
            Import-Module "$PSScriptRoot\AssistDeploy" -Force
        }
        else {
            if (Test-Path $LocalModulePath) {
                Write-Host "Installing AssistDeploy from supplied path $localModulePath" -ForegroundColor White -BackgroundColor DarkMagenta
                Import-Module $LocalModulePath -Force
            }
            else {
                Write-Error "Local Module of AssistDeploy not found at path supplied."
                Throw
            }
        }
        if (!$rollback) {
            Invoke-AssistDeploy -json_file $WWI_SSIS_JSON -ispac_file $WWI_SSIS_ISPAC -connection_string $InstanceUnderUse
        }
        else {
            if ($SimulateFailedDeployment) {
                Invoke-AssistDeployRollback -json_file $WWI_SSIS_JSON -ispac_file $WWI_SSIS_ISPAC -connection_string $InstanceUnderUse -SimulateFailure
            }
            else {
                Invoke-AssistDeployRollback -json_file $WWI_SSIS_JSON -ispac_file $WWI_SSIS_ISPAC -connection_string $InstanceUnderUse
            }
        }
    }
    else {
        Write-Host "SSIS deploy skipped. Add deploy switch to run build." -ForegroundColor Black -BackgroundColor Red
    }
}
Invoke-SSISBoD