Function Test-VisualStudio2017Installed{
    param(
        $vsPath
    )
    If ((Test-Path $vsPath) -eq $true)
    {
        Write-Host "Visual Studio Installed" -ForegroundColor DarkGreen
        Return $true
    }
    else {
        Write-Warning "Visual Studio 2017 not installed! We will not be able to build/edit isapc. Will use source-controlled ispac in bin/development folder." 
        Return $false
    }
}

