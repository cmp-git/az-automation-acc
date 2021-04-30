$Conn = Get-AutomationConnection -Name AzureRunAsConnection
Connect-AzAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint

Write-Output "Logged in to Azure"

foreach ($dbResourceId in (Get-AzResource -Tag @{ "Ltr Enabled" = "FALSE" }).ResourceId) {

    $dbName = ($dbResourceId -split '/')[10]
    Write-Output "The database to be backed up is :: [ $dbName ]"
    $serverName = ($dbResourceId -split '/')[8]
    Write-Output "The SQL server to which the SQL database belongs to  :: [ $serverName ]"
    $resourceGroup = ($dbResourceId -split '/')[4]
    Write-Output "The resourceGroup to which the SQL server belongs to  :: [ $resourceGroup ]"

    Set-AzSqlDatabaseBackupLongTermRetentionPolicy -ServerName $serverName -DatabaseName $dbName -ResourceGroupName $resourceGroup -WeeklyRetention P24W
    
    Write-Output "The LTR back up for database [ $dbName ] is scheduled "
    $tags = @{"Ltr Enabled" = "TRUE" }
    New-AzTag -ResourceId $dbResourceId -Tag $tags
    Write-Output "LTR ploicy has been applied and tag value updated successfully for :: [ $dbName ] "
    Write-Output "======================================================================================"

}
Write-Output "LTR ploicy has been applied for all newly created SQL databases"
