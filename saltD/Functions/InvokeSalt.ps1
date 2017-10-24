Function Invoke-Salt {
    param(
        $JobManifestXmlFile,
        $connection_string,
        [String]$MachineOrDomainName,
        [String]$userName
    )
    $global:RunAsAccount = "$MachineOrDomainName\$userName"
    Publish-Credential -sqlConnectionString $connection_string -RunAs $RunAsAccount
    Publish-Proxy -sqlConnectionString $connection_string -RunAs $RunAsAccount
    Write-Host "Setting RunAsAccount to $RunAsAccount" -ForegroundColor DarkBlue -BackgroundColor White
    Start-Sleep -Seconds 3
    Add-Type -Path "C:\Program Files\Microsoft SQL Server\140\SDK\Assemblies\Microsoft.SqlServer.Smo.dll"
    $SqlConnection = Connect-SqlConnection -ConnectionString $connection_string
    [xml] $_xml = [xml] (Get-Content -Path $JobManifestXmlFile)
    $x = Get-Xml -XmlFile $_xml
    Set-JobCategory -SqlServer $SqlConnection -root $x
    Set-JobOperator -SqlServer $SqlConnection -root $x
    $sqlAgentJob = Set-Job -SqlServer $SqlConnection -root $x
    Set-JobSchedules -SqlServer $SqlConnection -root $x -job $SqlAgentJob
    Set-JobSteps -SqlServer $SqlConnection -root $x -job $SqlAgentJob 
    Disconnect-SqlConnection -SqlDisconnect $SqlConnection
}