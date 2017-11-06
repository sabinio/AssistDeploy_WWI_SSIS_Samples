Clear-Host
#build and deploy databases
$svrConnstring = "SERVER=.;Integrated Security=True;Database=master"
$InvokeSSDTBoD = Join-Path $PSScriptRoot "\SSDTBoD\InvokeSSDTBoD.ps1"
. $InvokeSSDTBoD -InstanceUnderUse $svrConnstring -Build -Deploy
#build and deploy ssis packages
$InvokeSSISBoD = Join-Path $PSScriptRoot "\SSISBoD\InvokeSSISBoD.ps1"
. $InvokeSSISBoD -InstanceUnderUse $svrConnstring -Build -Deploy
Deploy SQL Agent Job
$InvokesaltD = Join-Path $PSScriptRoot "\saltD\InvokesaltD.ps1"
$pword = "what is your password"
# -MachineOrDomainName can be one of the two following:
#$env:USERDOMAIN
#$env:computername
. $InvokesaltD -InstanceUnderUse $svrConnstring -MachineOrDomainName $env:USERDOMAIN -userName $env:UserName -Password $pword -SQLAgentServerName $env:computername -IntegrationServicesCatalogServer $env:computername -LocalModulePath "c:\Users\richardlee\repos\AssistDeploy_WWI_SSIS_Samples\saltD\salt"