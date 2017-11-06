Function Invoke-Salt {
    param(
        $JobManifestXmlFile,
        $connection_string,
        [String]$MachineOrDomainName,
        [String]$userName,
        [String]$password
    )
    $global:RunAsAccount = "$MachineOrDomainName\$userName"
    $global:ServerJobCategory = "My Other Little Category"
    Publish-Credential -sqlConnectionString $connection_string -RunAs $RunAsAccount -Password $Password
    Publish-Proxy -sqlConnectionString $connection_string -RunAs $RunAsAccount
    Write-Host "Setting RunAsAccount to $RunAsAccount" -ForegroundColor DarkBlue -BackgroundColor White
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