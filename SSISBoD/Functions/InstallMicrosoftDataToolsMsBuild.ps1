

function Install-AssistDeploy {

    param ( [string] $WorkingFolder,
        [String] $NugetPath
        , [string] $PackageVersion
    )

    if (-Not $WorkingFolder) {
        Throw "Working folder needs to be set. Its blank"
    }
    Write-Verbose "Verbose Folder  (with Verbose) : $WorkingFolder" -Verbose

    Write-Verbose "AssistDeploy Version : $PackageVersion" -Verbose
    Write-Warning "If PackageVersion is blank latest will be used"
    $NugetExe = "$NugetPath\nuget.exe"
    if (-not (Test-Path $NugetExe)) {
        Write-Error "Cannot find nuget at path $NugetPath\nuget.exe"
        exit 1
    }
    $nugetInstallMsbuild = "&$NugetExe install AssistDeploy -ExcludeVersion -OutputDirectory $WorkingFolder"
    if ($PackageVersion) {
        $nugetInstallMsbuild += "-version '$PackageVersion'"
    }
    Write-Host $nugetInstallMsbuild -BackgroundColor White -ForegroundColor DarkGreen
    Invoke-Expression $nugetInstallMsbuild

    $SSDTMSbuildFolder = "$WorkingFolder\AssistDeploy"
    if (-not (Test-Path $SSDTMSbuildFolder)) {
        
        Throw "It appears that the nuget install hasn't worked, check output above to see whats going on"
    }
}
