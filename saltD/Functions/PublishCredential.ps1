Function Publish-Credential {
    param(
        $SqlConnectionString,
        $RunAs,
        $Password
    )
    $sql_connection = new-object System.Data.SqlClient.SqlConnection ($SqlConnectionString)
    Write-Verbose "Checking if credential $RunAs exists. If not will create..." -Verbose
    $check = $null
    try {
        $sql_connection.Open()
        $sql_connection.ChangeDatabase("master")
        $sqlExecute = "
    IF NOT EXISTS (select name from master.sys.credentials
    where name = '$RunAs')
    SELECT 'NOTEXISTS'
    "
    Write-Host $sqlExecute
        $sqlCommand = New-Object System.Data.SqlClient.SqlCommand($sqlExecute, $sql_connection)

        $Check = $sqlCommand.ExecuteScalar()
        if ($check -eq "NOTEXISTS") {
            Write-Warning "Creating Credential on instance."
            $sqlExecute = "
            CREATE CREDENTIAL [$RunAs] WITH IDENTITY = '$RunAs', SECRET = N'$Password'
            "
            $sqlCommand = New-Object System.Data.SqlClient.SqlCommand($sqlExecute, $sql_connection)
            $sqlCommand.ExecuteNonQuery() | Out-Null
            Write-Verbose "Credential for $RunAs created!" -Verbose
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