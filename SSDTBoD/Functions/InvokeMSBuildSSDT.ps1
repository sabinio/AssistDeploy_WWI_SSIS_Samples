

function Invoke-MsBuildSSDT {
    param ( [string] $DatabaseSolutionFilePath
        , [string] $DataToolsFilePath)
        
        $msbuild = "C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe"
        if (-not (Test-Path $msbuild)) {
            Write-Warning "No MSBuild installed. Install MSBuild using BuildTools_Full.exe provided."
            Invoke-WebRequest "https://download.microsoft.com/download/E/E/D/EEDF18A8-4AED-4CE0-BEBE-70A83094FC5A/BuildTools_Full.exe" -OutFile "$env:TEMP\BuildTools_Full.exe" -UseBasicParsing
            & "$env:TEMP\BuildTools_Full.exe" /Silent /Full
        }
    $arg1 = "/p:tv=14.0"
    $arg2 = "/p:SSDTPath=$DataToolsFilePath"
    $arg3 = "/p:SQLDBExtensionsRefPath=$DataToolsFilePath"
    $arg4 = "/p:Configuration=Debug"

    Write-Host $msbuild $DatabaseSolutionFilePath $arg1 $arg2 $arg3 $arg4 -ForegroundColor White -BackgroundColor DarkGreen
    & $msbuild $DatabaseSolutionFilePath $arg1 $arg2 $arg3 $arg4
}
