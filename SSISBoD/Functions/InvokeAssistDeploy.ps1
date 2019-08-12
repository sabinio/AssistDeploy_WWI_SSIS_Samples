Function Invoke-AssistDeploy {
    param(
        $json_file,
        $ispac_file,
        $connection_string
    )
    Write-Host "the connection string $connection_string"
    $myJsonPublishProfile = Import-Json -jsonPath $json_file -ispacPath $ispac_file -localVariables
    $ssisdb = Connect-SsisdbSql -sqlConnectionString $connection_string
    Test-Currentpermissions -sqlConnection $ssisdb
    Publish-SsisFolder -jsonPsCustomObject $myJsonPublishProfile -sqlConnection $ssisdb 
    Publish-SsisEnvironment -jsonPsCustomObject $myJsonPublishProfile -sqlConnection $ssisdb 
    Publish-SsisIspac -jsonPsCustomObject $myJsonPublishProfile -sqlConnection $ssisdb -ispacToDeploy $ispac_file 
    Publish-SsisEnvironmentReference -jsonPsCustomObject $myJsonPublishProfile -sqlConnection $ssisdb 
    Publish-SsisVariables -jsonPsCustomObject $myJsonPublishProfile -sqlConnection $ssisdb -localVariables 
    Disconnect-SsisdbSql -sqlConnection $ssisdb
}