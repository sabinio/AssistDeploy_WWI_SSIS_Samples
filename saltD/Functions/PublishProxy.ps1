Function Publish-Proxy {
    param(
        $SqlConnectionString,
        $RunAs
    )
    $sql_connection = new-object System.Data.SqlClient.SqlConnection ($SqlConnectionString)
    Write-Verbose "Checking if proxy $RunAs exists. If not will create..." -Verbose
    $check = $null
    try {
        $sql_connection.Open()
        $sql_connection.ChangeDatabase("msdb")
        $sqlExecute = "
    IF NOT EXISTS (select * from dbo.sysproxies
        where name = @0)
    SELECT 'NOTEXISTS'
    "
        $sqlCommand = New-Object System.Data.SqlClient.SqlCommand($sqlExecute, $sql_connection)
        $sqlCommand.Parameters.AddWithValue("@0", $RunAs) | Out-Null
        $Check = $sqlCommand.ExecuteScalar()
        if ($check -eq "NOTEXISTS") {
            Write-Warning "Creating Proxy $RunAs on instance."
            $sqlExecute = "
            EXEC msdb.dbo.sp_add_proxy @proxy_name=@0,@credential_name=@0, 
            @enabled=1
            "
            $sqlCommand = New-Object System.Data.SqlClient.SqlCommand($sqlExecute, $sql_connection)
            $sqlCommand.Parameters.AddWithValue("@0", $RunAs) | Out-Null
            $sqlCommand.ExecuteNonQuery() | Out-Null
            Write-Verbose "Proxy for $RunAs created!" -Verbose
        }
    }
    catch {
        Write-Error $_.Exception
        Throw
    }
    try {
        $sqlExecute = "
        EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=@0, @subsystem_id=11
        "
        $sqlCommand = New-Object System.Data.SqlClient.SqlCommand($sqlExecute, $sql_connection)
        $sqlCommand.Parameters.AddWithValue("@0", $RunAsAccount) | Out-Null
        $sqlCommand.ExecuteNonQuery() | Out-Null
        Write-Verbose "permissions for $RunAsAccount updated!" -Verbose
        
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