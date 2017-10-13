Function Invoke-SSISBuild{
    param(
        $vsPath,
        $SSIS_PROJ,
        $SSIS_SLN,
        $config
    )
    Write-Host "Beginning build ssis project. Refer to output below for command run." -ForegroundColor DarkMagenta
    Write-Host "$vsPath /rebuild $config /project $SSIS_PROJ /projectconfig $config $SSIS_SLN" -ForegroundColor White -BackgroundColor DarkGreen
    try {
        & $vsPath /rebuild $config /project $SSIS_PROJ /projectconfig $config $SSIS_SLN
    }
    catch {
        $_.Exception
    }
    
}