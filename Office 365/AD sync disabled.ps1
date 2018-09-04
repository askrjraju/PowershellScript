$UserCredential = Get-Credential
Connect-MsolService -Credential $UserCredential
Set-MsolDirSyncEnabled -EnableDirSync $false

Get-MSOLCompanyInformation).DirectorySynchronizationEnabled