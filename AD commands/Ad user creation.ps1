Get-Module -Listavailable
Set-ExecutionPolicy Unrestricted
Import-Csv C:\Scripts\NewUser.csv | New-ADUser -PassThru | Set-ADAccountPassword -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "Pass@1234"-Force) -PassThru |Enable-ADAccount