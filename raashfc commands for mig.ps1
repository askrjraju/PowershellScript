$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session 
Connect-MsolService

Get-MsolAccountSku
$AccountSku = Get-MsolAccountSku


import-csv -Path c:\users\040757\Desktop\user1.csv| %{New-MsolUser -UserPrincipalName $_.UPN -FirstName $_.FN -LastName $_.LN -DisplayName $_.DN -Title $_.JOB -Department $_.DEP -City $_.City -State $_.state -PostalCode $_.ZIP -Country $_.Country -PhoneNumber $_.office -MobilePhone $_.mobile -UsageLocation "IN" -Password raas@1234}

Import-Csv -Path c:\users\040757\Desktop\user1.csv|foreach {Remove-mailcontact -identity $_.UPN -Confirm:$false}

Import-Csv -Path c:\users\040757\Desktop\user1.csv|foreach {Set-MsolUserlicense -UserPrincipalName $_.UPN -AddLicenses "rhfl:SMB_BUSINESS_ESSENTIALS"}

Import-Csv -Path c:\users\040757\Desktop\user1.csv|foreach {Set-Mailbox -Identity $_.UPN -EmailAddresses $_.UPN, $_.alias, $_.SIP}

Import-Csv -Path c:\users\040757\Desktop\user1.csv|foreach {Get-Mailbox -Identity $_.UPN|Select-Object name, emailaddresses}