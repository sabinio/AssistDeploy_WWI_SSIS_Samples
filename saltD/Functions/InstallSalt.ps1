

function Install-Salt {

    param ( [string] $WorkingFolder,
        [String] $NugetPath
        , [string] $PackageVersion
        , [Switch] $IncludePreRelease
    )

    if (-Not $WorkingFolder) {
        Throw "Working folder needs to be set. Its blank"
    }
    Write-Verbose "Verbose Folder  (with Verbose) : $WorkingFolder" -Verbose

    Write-Verbose "salt Version : $PackageVersion" -Verbose
    Write-Warning "If PackageVersion is blank latest will be used"
    $NugetExe = "$NugetPath\nuget.exe"
    if (-not (Test-Path $NugetExe)) {
        Write-Error "Cannot find nuget at path $NugetPath\nuget.exe"
        exit 1
    }
    $nugetInstallMsbuild = "&$NugetExe install salt"
    if ($PackageVersion) {
        $nugetInstallMsbuild += " -version '$PackageVersion'"
    }
    if ($IncludePreRelease)
    {
        $nugetInstallMsbuild += " -PreRelease"
    }

    $nugetInstallMsbuild +=" -PackageSaveMode `"nuspec;nupkg`" -ExcludeVersion -OutputDirectory $WorkingFolder"
    Write-Host $nugetInstallMsbuild -BackgroundColor White -ForegroundColor DarkGreen
    Invoke-Expression $nugetInstallMsbuild

    $saltFolder = "$WorkingFolder\salt"
    Write-Host $saltFolder -ForegroundColor DarkCyan -BackgroundColor White
    if (-not (Test-Path $saltFolder)) {
        
        Throw "It appears that the nuget install hasn't worked, check output above to see whats going on"
    }
}
