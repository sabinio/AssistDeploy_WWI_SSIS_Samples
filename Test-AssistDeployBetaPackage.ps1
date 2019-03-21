Function Test-AssistDeployBetaPackage{
    param(
        [String]$pword
    )
    
    $global:RunAsAccount = "$Env:computername\$env:UserName"
    $global:ServerJobCategory = "My Other Little Category"
    $global:SQLAgentServerName = "$env:computername"
    $global:IntegrationServicesCatalogServer = "$env:computername"

# $svrConnstring = "SERVER=.;Integrated Security=True;Database=master"
# # $InvokeSSDTBoD = Join-Path $PSScriptRoot "\SSDTBoD\InvokeSSDTBoD.ps1"
# # . $InvokeSSDTBoD -InstanceUnderUse $svrConnstring -Build -Deploy
 $InvokeSSISBoD = Join-Path $PSScriptRoot "\SSISBoD\InvokeSSISBoD.ps1"
 . $InvokeSSISBoD -InstanceUnderUse $svrConnstring -IncludePreRelease #-Deploy
# #Deploy SQL Agent Job
# #$env:USERDOMAIN
# #$env:computername
# $InvokesaltD = Join-Path $PSScriptRoot "\saltD\InvokesaltD.ps1"
# . $InvokesaltD -InstanceUnderUse $svrConnstring -MachineOrDomainName $env:computername -userName $env:UserName -Password $pword -SQLAgentServerName $env:computername -IntegrationServicesCatalogServer $env:computername
}
Write-Host "Sleeping for 1 minute so that package can be indexed on NuGet."
#Start-Sleep -Seconds 60
$BuildPassword = "Yanmega#0469"
Test-AssistDeployBetaPackage -pword $env:BuildPassword