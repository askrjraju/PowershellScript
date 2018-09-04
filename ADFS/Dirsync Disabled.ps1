Set-MsolDirSyncEnabled -EnableDirSync $false

Get-MSOLCompanyInformation).DirectorySynchronizationEnabled

Set-ADSyncScheduler -SyncCycleEnabled $false