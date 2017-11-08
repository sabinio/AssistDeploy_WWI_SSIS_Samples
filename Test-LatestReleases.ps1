Function Test-LatestReleases{
    param(
        [String]$pword
    )
    
    $global:RunAsAccount = "$Env:computername\$env:UserName"
    $global:ServerJobCategory = "My Other Little Category"
    $global:SQLAgentServerName = "$env:computername"
    $global:IntegrationServicesCatalogServer = "$env:computername"

$svrConnstring = "SERVER=.;Integrated Security=True;Database=master"
$InvokeSSDTBoD = Join-Path $PSScriptRoot "\SSDTBoD\InvokeSSDTBoD.ps1"
. $InvokeSSDTBoD -InstanceUnderUse $svrConnstring -Build -Deploy
$InvokeSSISBoD = Join-Path $PSScriptRoot "\SSISBoD\InvokeSSISBoD.ps1"
. $InvokeSSISBoD -InstanceUnderUse $svrConnstring -Build -Deploy
#Deploy SQL Agent Job
#$env:USERDOMAIN
#$env:computername
$InvokesaltD = Join-Path $PSScriptRoot "\saltD\InvokesaltD.ps1"
. $InvokesaltD -InstanceUnderUse $svrConnstring -MachineOrDomainName $env:computername -userName $env:UserName -Password $pword -SQLAgentServerName $env:computername -IntegrationServicesCatalogServer $env:computername
}

Test-LatestReleases -pword $env:BuildPassword