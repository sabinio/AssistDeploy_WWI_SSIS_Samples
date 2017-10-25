$InvokeSSISBoD = Join-Path $PSScriptRoot "\SSISBoD\InvokeSSISBoD.ps1"
. $InvokeSSISBoD -InstanceUnderUse $svrConnstring -Deploy -rollback -SimulateFailedDeployment