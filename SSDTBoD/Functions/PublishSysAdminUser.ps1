Function Publish-SysAdminUser {
    param(
        $SqlConnectionString 
    )
    $sql_connection = new-object System.Data.SqlClient.SqlConnection ($SqlConnectionString)
    Write-Verbose "Checking if AssistDeploy SQL Login exists. If not will create with sysadmin rights..." -Verbose
    $check = $null
    try {
        $sql_connection.Open()
        $sqlExecute = "
    IF NOT EXISTS (SELECT loginname FROM master.dbo.syslogins 
    where name = 'AssistDeploy' and dbname = 'master')
    SELECT 'NOTEXISTS'
    "
        $sqlCommand = New-Object System.Data.SqlClient.SqlCommand($sqlExecute, $sql_connection)
        $Check = $sqlCommand.ExecuteScalar()
        if ($check -eq "NOTEXISTS") {
            Write-Warning "Creating SQL Login AssistDeploy on instance."
            $sqlExecute = "
            CREATE LOGIN [AssistDeploy] WITH PASSWORD=N'919c36be-3dd9-4fb8-b9dd-a038d45ed63e', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
            ALTER SERVER ROLE [sysadmin] ADD MEMBER [AssistDeploy]
            "
            $sqlCommand = New-Object System.Data.SqlClient.SqlCommand($sqlExecute, $sql_connection)
            $sqlCommand.ExecuteNonQuery() | Out-Null
            Write-Verbose "login AssistDeploy Created!" -Verbose
        }
    }
    catch {
        Write-Error $_.Exception
        Throw
    }
    if ($null -eq $check)
    {
        Write-Verbose "Login already created." -Verbose
    }
    $sql_connection.Dispose();
}