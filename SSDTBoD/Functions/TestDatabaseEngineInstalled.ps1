Function Test-DatabaseEngineInstalled {
    Write-Verbose "Checking to see if SQL Sever 2016 or 2017 are installed locally." -Verbose
    [boolean] $sqlInstalled = $false
    if (Test-Path "HKLM:\Software\Microsoft\Microsoft SQL Server\140") {
        $sqlInstalled = $true
    }
    Else {
        if (Test-Path "HKLM:\Software\Microsoft\Microsoft SQL Server\140") {
            $sqlInstalled = $true
        }
    }
    if ($sqlInstalled -ne $true)
    {
        Write-Error "SQL Server Database Engine not installed. Please installeither SQl Server 2016 or 2017 and try again."
        Throw
    }
    else {
        Write-Host "SQL Server Installed." -ForegroundColor Green
    }
}
