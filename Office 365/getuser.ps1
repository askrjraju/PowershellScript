Import-Module ActiveDirectory
Get-ADUser -Filter *

Import-Csv -Path C:\AD_users.csv | foreach {Get-ADUser -Identity $_.UPN}| select userprincipalname

Get-ADUser -Filter * | Select Name, UserPrincipalName|Export-Csv C:\ExportADUsers.csv