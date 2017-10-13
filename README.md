# AssistDeploy_WWI_SSIS_Samples
This repo provides a sample set of projects, themselves taken from the [sql-server-samples](https://github.com/Microsoft/sql-server-samples) repo. These projects are then used to provide an example of how to deploy an Integration Services project using [AssistDeploy](https://github.com/sabinio/AssistDeploy/).

## Pre-requisites
Although nuget is used to install as much as possible, and BuildTools installer is included, therea re a few items of pre-requisites -  


### Non-opional
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
Clone or download the repo. Locate the "Start.ps1" file. Edit the connection string so that it points to your instance. 
