Function Invoke-Salt {
    param(
        $JobManifestXmlFile,
        $connection_string,
        [String]$MachineOrDomainName,
        [String]$userName,
        [String]$password
    )
    Publish-Credential -sqlConnectionString $connection_string -RunAs $RunAsAccount -Password $Password
    Publish-Proxy -sqlConnectionString $connection_string -RunAs $RunAsAccount
    Write-Host "Setting RunAsAccount to $RunAsAccount, Server Job Category to $serverJobCategory and SQL Agent Server name to $SQLAgentServerName" -ForegroundColor DarkBlue -BackgroundColor White
    Add-Type -Path "C:\Program Files\Microsoft SQL Server\140\SDK\Assemblies\Microsoft.SqlServer.Smo.dll"
    [xml] $_xml = [xml] (Get-Content -Path $JobManifestXmlFile)
    $x = Get-Xml -XmlFile $_xml
    $SqlConnection = Connect-SqlConnection -ConnectionString $connection_string
    Test-SQLServerAgentService -SqlServer $SqlConnection
    Test-CurrentPermissions -SqlServer $SqlConnection -ProxyCheck -root $x
    Set-JobCategory -SqlServer $SqlConnection -root $x
    Set-JobOperator -SqlServer $SqlConnection -root $x
    $sqlAgentJob = Set-Job -SqlServer $SqlConnection -root $x
    Set-JobSchedules -SqlServer $SqlConnection -root $x -job $SqlAgentJob
    Set-JobSteps -SqlServer $SqlConnection -root $x -job $SqlAgentJob 
    Disconnect-SqlConnection -SqlDisconnect $SqlConnection
}