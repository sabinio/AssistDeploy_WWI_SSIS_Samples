#build and deploy databases
$svrConnstring = "SERVER=.;Integrated Security=True;Database=master"
$InvokeSSDTBoD = Join-Path $PSScriptRoot "\SSDTBoD\InvokeSSDTBoD.ps1"
. $InvokeSSDTBoD -InstanceUnderUse $svrConnstring -Build -Deploy
#build and deploy ssis packages
$InvokeSSISBoD = Join-Path $PSScriptRoot "\SSISBoD\InvokeSSISBoD.ps1"
. $InvokeSSISBoD -InstanceUnderUse $svrConnstring -Build -Deploy