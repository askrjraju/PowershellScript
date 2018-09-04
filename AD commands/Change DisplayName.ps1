$Users = Get-ADUser -Filter * -SearchBase 'OU=office365,DC=vashishtpro,DC=com' -Properties Name

ForEach ($User in $Users) {
    $GivenName = ($User.name).split(' ')[0]
    $Surname = ($User.name).split(' ')[1]
    $DisplayName = $User.Name
    Set-ADUser -Identity $User.SamAccountName -GivenName $Givenname -Surname $Surname -DisplayName $DisplayName
    Clear-Variable GivenName,Surname
}

