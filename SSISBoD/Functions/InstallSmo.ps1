

function Install-Smo {

    param ( [string] $WorkingFolder,
        [String] $NugetPath
        , [string] $PackageVersion
        ,[Switch] $IncludePreRelease
    )

    if (-Not $WorkingFolder) {
        Throw "Working folder needs to be set. Its blank"
    }
    Write-Verbose "Verbose Folder  (with Verbose) : $WorkingFolder" -Verbose

    Write-Verbose "Smo Version : $PackageVersion" -Verbose
    Write-Warning "If PackageVersion is blank latest will be used"
    $NugetExe = "$NugetPath\nuget.exe"
    if (-not (Test-Path $NugetExe)) {
        Write-Error "Cannot find nuget at path $NugetPath\nuget.exe"
        exit 1
    }
    $nugetInstall = "&$NugetExe install Microsoft.SqlServer.SqlManagementObjects "
    if ($PackageVersion) {
        $nugetInstall += "-version '$PackageVersion'"
    }
    if ($IncludePreRelease)
    {
        $nugetInstall += " -PreRelease"
    }
    $nugetInstall +=  " -PackageSaveMode `"nuspec;nupkg`" -ExcludeVersion -OutputDirectory $WorkingFolder"
    Write-Host $nugetInstall -BackgroundColor White -ForegroundColor DarkGreen
    Invoke-Expression $nugetInstall

    $smoFolder = "$WorkingFolder\Microsoft.SqlServer.SqlManagementObjects\lib\net45\Microsoft.SqlServer.Smo.dll"
    $smoFolder = Resolve-Path $smoFolder
    if (-not (Test-Path $smoFolder)) {
        
        Throw "It appears that the nuget install hasn't worked, check output above to see whats going on"
    }
}
