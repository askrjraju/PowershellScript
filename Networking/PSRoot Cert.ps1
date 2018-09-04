$cert = New-SelfSignedCertificate -Type Custom -KeySpec Signature `
-Subject "CN=CLEXAZRoot" -KeyExportPolicy Exportable `
-HashAlgorithm sha256 -KeyLength 2048 `
-CertStoreLocation "Cert:\CurrentUser\My" -KeyUsageProperty Sign -KeyUsage CertSign -NotAfter(Get-Date).AddMonths(60)

New-SelfSignedCertificate -Type Custom -KeySpec Signature `
-Subject "CN=CLEXAZClient" -KeyExportPolicy Exportable `
-HashAlgorithm sha256 -KeyLength 2048 `
-CertStoreLocation "Cert:\CurrentUser\My" `
-Signer $cert -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2") -NotAfter(Get-Date).AddMonths(60)

 # By default expiry date of certificate is 1 year. We can increase it as we did in this command using -NotAfter