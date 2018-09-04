﻿$UserCredential = Get-Credential
Connect-MsolService -Credential $UserCredential
Set-MsolADFSContext –Computer adfs.vashishtpro.com
Convert-MsolDomainToFederated –DomainName vashishtpro.com
Get-MsolFederationProperty –DomainName vashishtpro.com

# federated to Standard
Set-MsolDomainAuthentication -Authentication Managed -DomainName " "