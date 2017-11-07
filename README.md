


[<img src="https://sabinio.visualstudio.com/_apis/public/build/definitions/573f7b7f-2303-49f0-9b89-6e3117380331/107/badge"/>](https://sabinio.visualstudio.com/Sabin.IO/_apps/hub/ms.vss-ciworkflow.build-ci-hub?_a=edit-build-definition&id=107)


# AssistDeploy_WWI_SSIS_Samples

Before we get into this, a disclaimer - 
**Please don't run this software anywhere expect on a local machine. EG don't try this on a shared instance of SQL Server. Best thing to do is to get a VM up and running and play around on that**

This repo provides a sample set of projects, themselves taken from the [sql-server-samples](https://github.com/Microsoft/sql-server-samples) repo. These projects are then used to provide an example of how to deploy an Integration Services project using [AssistDeploy](https://github.com/sabinio/AssistDeploy/). Additionally a SQL Server Agent Job can be deployed to the server, based on [salt](https://github.com/sabinio/salt/)

## Pre-requisites
Although nuget is used to install as much as possible, and BuildTools installer is included, there are a few items of pre-requisites


### Non-optional
* SQL Server 2016 or 2017 Database Engine
* SQL /Mixed-mode authentication
* SQL Server 2016 or 2017 Integration Services
* SSIS Catalog created.

### Optional
* Visual Studio 2017
* SSDT Daatabase and Integration Services 15.1 for Visual Studio 2017.

#### What Happens If I Don't Have The Optional Pre-Requisites Installed?
You won't be able to build the SSIS Project. The Ispac is included in the repo, so you can deploy using that.
You also won't be able open the solution to make any changes.

## Getting Started

In the [json file](https://github.com/sabinio/AssistDeploy_WWI_SSIS_Samples/blob/master/WWI_SSIS/WWI_SSIS_ETL.json) you need to update the server name to the server you are deploying to. 
Clone or download the repo. Locate the "Start.ps1" file. This is all you need to executeto build/deploy the whole sample.

#### What parameters do I need to change?
You need to update the connection string to the server that you are deploying to, and you need to enter the password for the user you are currently logged in as.The password is used when we create the credential and proxy in SQL Server. These are used so that the "RunAs" account has permissions to execute the SQL Agent step, which runs the Integration Services package.

To skip the build or deploy of either the database or ssis project, exclude the switches (lines 4, 7). 
```powershell
#build and deploy databases
$svrConnstring = "SERVER=.;Integrated Security=True;Database=master"
$InvokeSSDTBoD = Join-Path $PSScriptRoot "\SSDTBoD\InvokeSSDTBoD.ps1"
. $InvokeSSDTBoD -InstanceUnderUse $svrConnstring -Build -Deploy
#build and deploy ssis packages
$InvokeSSISBoD = Join-Path $PSScriptRoot "\SSISBoD\InvokeSSISBoD.ps1"
. $InvokeSSISBoD -InstanceUnderUse $svrConnstring -Build -Deploy
#Deploy SQL Agent Job
$pword = "WindowsLogonPassword"
$InvokesaltD = Join-Path $PSScriptRoot "\saltD\InvokesaltD.ps1"
. $InvokesaltD -InstanceUnderUse $svrConnstring -MachineOrDomainName $env:computername -userName $env:UserName -Password $pword -SQLAgentServerName $env:computername -IntegrationServicesCatalogServer $env:computername
```

## What is this Samples Project Doing?

There are three parts to the Start file - 

launch the InvokeSSDTBoD.ps1 Script
launch the InvokeSSISBoD.ps1 Script
launch the InvokesaltD.ps1 Script

All three of these scripts import a module that is used to complete whatever task is required - ie build/deploy. They also set up the variables required to execute the build/deploy.

The three modules are - 
SSDTBoD
SSISBoD
saltD

The following sub sections go into greater detail of each "Invoke..." script and their respective modules. The names of the functions within each module are in brackets.

### InvokeSSDTBoD
#### Summary -
The InvokeSSDTBoD.ps1 script imports the module SSDTBoD, which will run some checks before building/deploying the database projects require by the SSIS sample project.

You can skip either the build/deploy process by ommiting the build/deploy switches in the start.ps1 script. If the build is removed then the "deploy" switch, if included, uses what's in the bin folders. If both are removed then nothing happens!

As mentioned above, this samples project uses projects from the sql-server-samples repo. So in order to use the ssis sample project, we need to set up the databases first. The script sets up all the variables required.
```powershell
$WWI_OLTP_NAME = "WideWorldImporters"
$WWI_DW_NAME = "WideWorldImportersDW"
#etc...
    $WWI_DW = Join-Path (Split-Path -Path $PSScriptRoot -Parent) "\WWI_DW_SSDT\wwi-dw-ssdt"
    $WWI_OLTP = Join-Path (Split-Path -Path $PSScriptRoot -Parent) "\WWI_SSDT\wwi-ssdt"
#etc...
```

Before we build/deploy the databases, we check that the minimum version of .NET is installed (Test-Net461Installed), and that SQL Server is installed (Test-DatabaseEngineInstalled).

The SSDTBoD module uses the Microsoft.Data.Tools.MSBuild nuget package to compile the solution (Invoke-MsBuildSSDT). But before it can use the Nuget package, it downloads it from Nuget (Install-MicrosoftDataToolsMSBuild). It ill always download the latest one.
```powershell
    Install-MicrosoftDataToolsMSBuild -WorkingFolder $WWI_OLTP -NugetPath $PSScriptRoot

    Invoke-MsBuildSSDT -DatabaseSolutionFilePath $WWI_OLTP_SLN -DataToolsFilePath $WWI_OLTP_DAC 
``` 

The database project is then deployed. After the projets are deployed we add SQL Login with sysadmin rights. This is used by SSISBoD when publishing the environment variables. 
```powershell
    Publish-DatabaseDeployment -dacfxPath $WWI_OLTP_DACFX -dacpac $WWI_OLTP_DACPAC -publishXml $WWI_OLTP_PUB -targetConnectionString $InstanceUnderUse -targetDatabaseName $WWI_OLTP_NAME
    Publish-SysAdminUser -SqlConnectionString $InstanceUnderUse
 ```

### InvokeSSISBoD
#### Summary
The InvokeSSDTBoD.ps1 script imports the module SSISBoD, which will run some checks before building/deploying the ssis project. This is where AssitDeploy is used.

```powershell
Import-Module  ".\SSISBoD" -Force
    $WWI_SSIS = Join-Path (Split-Path -Path $PSScriptRoot -Parent) "\WWI_SSIS"
    $WWI_SSIS_SLN = Join-Path (Split-Path -Path $PSScriptRoot -Parent) "Assist_Deploy_WWI_SSIS_Samples.sln"
```

If the build switch is included, we check that Visual Studio 2017 is installed (Test-VisualStudio2017Installed), and if it is we compile the project using devenv.com (Invoke-SsisBuild). Any version of VS2017 is suitable. If the buildswitch is ommited, then what is stored in the bin fodler is used. 

```powershell
if ($build) {
        $devenv = 'C:\Program Files (x86)\Microsoft Visual Studio\2017\*\Common7\IDE\devenv.com'
        [boolean]$what = Test-VisualStudio2017Installed -vspath $devenv 
        if ($what -eq $true) {
            Write-Host "As Visual Studio 2017 is installed, we can build dtproj file." -ForegroundColor DarkMagenta
            Write-Host "If you want to open the project, you need to have at least SSDT 15.1 installed." -ForegroundColor Black -BackgroundColor Yellow
            Invoke-SsisBuild -vspath $devenv -ssis_proj $wwi_ssis_proj -ssis_sln $WWI_SSIS_SLN -config "Development"
        }
    }
```

If the deploy switch isused, we first get the latst version of AssistDeploy from NuGet (Install-AssistDeploy), and then use AssistDeploy to deploy the ispac and corresponding json file (Invoke-AssistDeploy). For more info about AssistDeploy consult the readme on the repo for [AssistDeploy](https://github.com/sabinio/AssistDeploy). But in brief, we load the config from the json file, create a connection to the SQL Server and deploy the changes - 

```powershell
    $myJsonPublishProfile = Import-Json -jsonPath $json_file -ispacPath $ispac_file -localVariables
    $ssisdb = Connect-SsisdbSql -sqlConnectionString $connection_string
    Publish-SsisFolder -jsonPsCustomObject $myJsonPublishProfile -sqlConnection $ssisdb 
    Publish-SsisEnvironment -jsonPsCustomObject $myJsonPublishProfile -sqlConnection $ssisdb 
    Publish-SsisIspac -jsonPsCustomObject $myJsonPublishProfile -sqlConnection $ssisdb -ispacToDeploy $ispac_file 
    Publish-SsisEnvironmentReference -jsonPsCustomObject $myJsonPublishProfile -sqlConnection $ssisdb 
    Publish-SsisVariables -jsonPsCustomObject $myJsonPublishProfile -sqlConnection $ssisdb -localVariables 
    Disconnect-SsisdbSql -sqlConnection $ssisdb
```
This sample makes use of the localvariables switch, in that whatever values for environment referecnes that are stored within the json file are use when deploying. We can parameterise these values, but with the sample it's just easier to use wat's i nthe json. To know more about parameterising, read [this article](https://sabin.io/blog/migrating-ssis-packages-to-ssis-azure-part-twoautomating-the-deployment/).

#### What's With The LocalModulePath parameter?
As this sample project is used for testing, you can add a local path to the AssistDeploy module. This is an alternative to downloading the latest version from Nuget.

```powershell
if (!$LocalModulePath) {
            Write-Host "Installing AssistDeploy from Nuget" -ForegroundColor White -BackgroundColor DarkMagenta
            Install-AssistDeploy -WorkingFolder $PSScriptRoot -NugetPath $PSScriptRoot 
            Import-Module "$PSScriptRoot\AssistDeploy" -Force
        }
        else {
            if (Test-Path $LocalModulePath) {
                Write-Host "Installing AssistDeploy from supplied path $localModulePath" -ForegroundColor White -BackgroundColor DarkMagenta
                Import-Module $LocalModulePath -Force
            }
            else {
                Write-Error "Local Module of AssistDeploy not found at path supplied."
                Throw
            }
        }
```

#### What's With The Rollback and SimulateFailedDeployment Switches?
Ignore these for now. These are to be discussed at a later date.

#### No come on, I'm Curious, What's The Point of Them?
Consult the startRollback script, they are used there. The "SimulateFailedDeployment" switch will alter a variable so that AssistDeploy returns a failed deplyoment irrespective of whether a deployment has failed or not. 

Wrt rollback - Basically there's the functionality in SSISDB to rollback a failed deployment of an ispac. But it's more complicated than that because environment variable changes are not rolled back when you roll a project back to a previous version, so you have to backup an environment first. I've put this functionality in AssistDeploy, so the rollback switch executes the extra functions requiredto rollbak a failed deployment successfully, but I have not documented anywhere. As metioned, this will be discussed in the AssistDeploy repo at some point and this readme will reference that in detail. Generally I wouldn't advise using it - it's a prime example of why you should fail forward rather than rollback.


### InvokesaltD
#### Summary
Takes the .xml file that is stored in the WWI_SSIS folder and creates a SQl Agent Job. Any subsequent chagnes to the XML file will alter the job on the server. 

InvokesaltD does not require either the build or deploy switches as there is nothing to compile, and because all it essentially does is compile. However it does require quite a few varaibles - 
```powershell
    [String]$InstanceUnderUse, #the connection string from start.ps1
    [String]$MachineOrDomainName, #used to create the credential/proxy on the sql server instacne we deploy the SQL Agent Job to
    [String]$userName, #as above
    [String]$Password, #used for the credential
    [String]$SQLAgentServerName, #name of the instance we are deploying to
    [String]$IntegrationServicesCatalogServer, #name of hte instance that runs SQL Server Integration Services
    [string]$LocalModulePath #As this sample project is used for testing, you can add a local path to the salt module. This is an alternative to downloading the latest version from Nuget.
```

Much of hte script sets up variables and imports either a local copy of salt or downloads it from Nuget (Install-salt) - 
```powershell
   Import-Module  ".\saltD" -Force
    $WWI_SSIS = Join-Path (Split-Path -Path $PSScriptRoot -Parent) "\WWI_SSIS"
    $WWI_SSIS_XML = Join-Path $WWI_SSIS "RunDailyETL.xml"
    if (!$LocalModulePath) {
        Write-Host "Installing salt from Nuget" -ForegroundColor White -BackgroundColor DarkMagenta
        Install-salt -WorkingFolder $PSScriptRoot -NugetPath $PSScriptRoot 
        Import-Module "$PSScriptRoot\salt" -Force
    }
    else {
        if (Test-Path $LocalModulePath) {
            Write-Host "Installing salt from supplied path $localModulePath" -ForegroundColor White -BackgroundColor DarkMagenta
            Import-Module $LocalModulePath -Force
        }
        else {
            Write-Error "Local Module of salt not found at path supplied."
            Throw
        }
    }
```
The function (Invoke-Salt) is where most of the magic happens - we create the "RunAs" account, create the proxy and credential used by the SQL Agent Job, and add SMO to the PowerShell session - 

```powershell

    $global:RunAsAccount = "$MachineOrDomainName\$userName"
    Publish-Credential -sqlConnectionString $connection_string -RunAs $RunAsAccount -Password $Password
    Publish-Proxy -sqlConnectionString $connection_string -RunAs $RunAsAccount
    Write-Host "Setting RunAsAccount to $RunAsAccount" -ForegroundColor DarkBlue -BackgroundColor White
    Add-Type -Path "C:\Program Files\Microsoft SQL Server\140\SDK\Assemblies\Microsoft.SqlServer.Smo.dll"
```
The rest of the function then uses functions that are in salt. Read up on the [salt readme](https://github.com/sabinio/salt/blob/master/README.md) for more information on how salt works.
```powershell
  $SqlConnection = Connect-SqlConnection -ConnectionString $connection_string
    [xml] $_xml = [xml] (Get-Content -Path $JobManifestXmlFile)
    $x = Get-Xml -XmlFile $_xml
    Set-JobCategory -SqlServer $SqlConnection -root $x
    Set-JobOperator -SqlServer $SqlConnection -root $x
    $sqlAgentJob = Set-Job -SqlServer $SqlConnection -root $x
    Set-JobSchedules -SqlServer $SqlConnection -root $x -job $SqlAgentJob
    Set-JobSteps -SqlServer $SqlConnection -root $x -job $SqlAgentJob 
    Disconnect-SqlConnection -SqlDisconnect $SqlConnection
```

#### What's With The LocalModulePath parameter?
As this sample project is used for testing, you can add a local path to the salt module. This is an alternative to downloading the latest version from Nuget.
## Unknown Unknowns

In the [ssis json](https://github.com/sabinio/AssistDeploy_WWI_SSIS_Samples/blob/master/WWI_SSIS/WWI_SSIS_ETL.json) file and in the [PublishSysAdminUser](https://github.com/sabinio/AssistDeploy_WWI_SSIS_Samples/blob/master/SSDTBoD/Functions/PublishSysAdminUser.ps1) file there are matching passwords used in the sample. These can be altered, however they must match.
The [PublishSysAdminUser](https://github.com/sabinio/AssistDeploy_WWI_SSIS_Samples/blob/master/SSDTBoD/Functions/PublishSysAdminUser.ps1) file creates a sql login with sysasmin privileges on the SQL Server instance.
