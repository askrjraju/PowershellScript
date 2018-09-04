Login-AzureRmAccount
$P2SRootCertName = "testcert.cer"
$filePathForCert = "C:\Users\embee\Desktop\testcert.cer"
    $cert = new-object System.Security.Cryptography.X509Certificates.X509Certificate2($filePathForCert)
    $CertBase64 = [system.convert]::ToBase64String($cert.RawData)
    $p2srootcert = New-AzureRmVpnClientRootCertificate -Name $P2SRootCertName -PublicCertData $CertBase64