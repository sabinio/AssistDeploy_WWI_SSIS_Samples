# AssistDeploy_WWI_SSIS_Samples
This repo provides a sample set of projects, themselves taken from the [sql-server-samples](https://github.com/Microsoft/sql-server-samples) repo. These projects are then used to provide an example of how to deploy an Integration Services project using [AssistDeploy](https://github.com/sabinio/AssistDeploy/). Additionally a SQl Server Agent Job can be deployed to the server, based on [salt](https://github.com/sabinio/salt/)

## Pre-requisites
Although nuget is used to install as much as possible, and BuildTools installer is included, there are a few items of pre-requisites


### Non-optional
SQL Server 2016 or 2017 Database Engine
SQL Server/Mixed-mode authentication
SQL Server 2016 or 2017 Integration Services
SSIS Catalog created.

### Optional
Visual Studio 2017
SSDT Daatabase and Integration Services 15.1 for Visual Studio 2017.

#### What Happens If I Don't Have These Installed?
You won't be able to build the SSIS Project. The Ispac is included in the repo, so you can deploy using that.
You also won't be able open the solution to make any changes.

## Getting Started

In the [json file](https://github.com/sabinio/AssistDeploy_WWI_SSIS_Samples/blob/master/WWI_SSIS/WWI_SSIS_ETL.json) you need to update the server name to the server you are deploying to. 
Clone or download the repo. Locate the "Start.ps1" file. Edit the connection string so that it points to your instance.

To skip the build or deploy of either the database or ssis project, exclude the switches (lines 4, 7). 
```powershell
#build and deploy databases
$svrConnstring = "SERVER=.;Integrated Security=True;Database=master"
$InvokeSSDTBoD = Join-Path $PSScriptRoot "\SSDTBoD\InvokeSSDTBoD.ps1"
. $InvokeSSDTBoD -InstanceUnderUse $svrConnstring -Build -Deploy
#build and deploy ssis packages
$InvokeSSISBoD = Join-Path $PSScriptRoot "\SSISBoD\InvokeSSISBoD.ps1"
. $InvokeSSISBoD -InstanceUnderUse $svrConnstring -Build -Deploy
```
## AssistDeploy Stuff

Consult the "AssistDeploy.ps1" file to see AssistDeploy executed.  

## Unknown Unknowns

In the [ssis json](https://github.com/sabinio/AssistDeploy_WWI_SSIS_Samples/blob/master/WWI_SSIS/WWI_SSIS_ETL.json) file and in the [PublishSysAdminUser](https://github.com/sabinio/AssistDeploy_WWI_SSIS_Samples/blob/master/SSDTBoD/Functions/PublishSysAdminUser.ps1) file there are matching passwords used in the sample. These can be altered, however they must match.
The [PublishSysAdminUser](https://github.com/sabinio/AssistDeploy_WWI_SSIS_Samples/blob/master/SSDTBoD/Functions/PublishSysAdminUser.ps1) file creates a sql login with sysasmin privileges on the SQL Server instance.
