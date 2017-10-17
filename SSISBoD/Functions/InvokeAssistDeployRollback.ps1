Function Invoke-AssistDeployRollback {
    param(
        $json_file,
        $ispac_file,
        $connection_string,
        [Switch] $simulateFailure
    )
    $myJsonPublishProfile = Import-Json -jsonPath $json_file -ispacPath $ispac_file -localVariables
    $ssisdb = Connect-SsisdbSql -sqlConnectionString $connection_string
    Publish-SsisFolder -jsonPsCustomObject $myJsonPublishProfile -sqlConnection $ssisdb
    Unpublish-SsisEnvironmentReference -jsonPsCustomObject $myJsonPublishProfile -sqlConnection $ssisdb
    $ssisLatestProjectLsn = Get-SsisProjectLsn -jsonPsCustomObject $myJsonPublishProfile -sqlConnection $ssisdb
    if ($ssisLatestProjectLsn) {
        $renamedSsisEnvironmentName = Edit-SsisEnvironmentName -jsonPsCustomObject $myJsonPublishProfile -ssisProjectLsn $ssisLatestProjectLsn -sqlConnection $ssisdb
        Unpublish-SsisEnvironmentReference -jsonPsCustomObject $myJsonPublishProfile -sqlConnection $ssisdb
        Unpublish-SsisEnvironmentReference -jsonPsCustomObject $myJsonPublishProfile -ssisEnvironmentName $renamedSsisEnvironmentName -sqlConnection $ssisdb
    }
    Publish-SsisEnvironment -jsonPsCustomObject $myJsonPublishProfile -sqlConnection $ssisdb
    Publish-SsisIspac -jsonPsCustomObject $myJsonPublishProfile -sqlConnection $ssisdb -ispacToDeploy $ispac_file
    Publish-SsisEnvironmentReference -jsonPsCustomObject $myJsonPublishProfile -sqlConnection $ssisdb
    Publish-SsisVariables -jsonPsCustomObject $myJsonPublishProfile -sqlConnection $ssisdb  -localVariables 
    $validationStatus = Invoke-ValidateSsisProject -jsonPsCustomObject $myJsonPublishProfile -sqlConnection $ssisdb
    if ($simulateFailure) {
        $validationStatus.statusValue = "uh oh"
    }
    if ($validationStatus.statusValue -ne "succeeded") {
        if ($null -ne $ssisLatestProjectLsn) {
            Unpublish-SsisDeployment -jsonPsCustomObject $myJsonPublishProfile -sqlConnection $ssisdb -ssisProjectLsn $ssisLatestProjectLsn
        }
        else {
            Unpublish-SsisDeployment -jsonPsCustomObject $myJsonPublishProfile -sqlConnection $ssisdb -delete
        }
        Unpublish-SsisEnvironment -jsonPsCustomObject $myJsonPublishProfile -sqlConnection $ssisdb
        Unpublish-SsisEnvironmentReference -jsonPsCustomObject $myJsonPublishProfile -sqlConnection $ssisdb
        if ($null -ne $ssisLatestProjectLsn) {
            Publish-SsisEnvironment -jsonPsCustomObject $myJsonPublishProfile -sqlConnection $ssisdb -ssisEnvironmentName $renamedSsisEnvironmentName
            Publish-SsisEnvironmentReference -jsonPsCustomObject $myJsonPublishProfile -sqlConnection $ssisdb -ssisEnvironmentName $renamedSsisEnvironmentName
        }
    }
    Disconnect-SsisdbSql -sqlConnection $ssisdb
}