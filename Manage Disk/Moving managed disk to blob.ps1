Step 2 – Copy the snapshot to Blob

The next part relies on PowerShell. Update the following PowerShell script with your parameters to copy the snapshot to Blob:

$storageAccountName = "mdiskst"
$storageAccountKey = “cVx0ltd/s7M3WFzsyNJSJlC7T22O4HURWP2yEFqXTfUVAhVv/Id3mEHLZ/totxLborPhWOEpS3noDiby3hzz4g==”
$absoluteUri = “https://md-whjdhvb300l3.blob.core.windows.net/s2h25xd1zgx1/abcd?sv=2016-05-31&sr=b&si=69d6e3a3-3fd3-4906-98fb-8ae47d702653&sig=xPUYa39Y2PGbg9UgHEZX92DFofZc%2BSy3qb%2BlQYv8xiU%3D"
$destContainer = “vhds”
$blobName = “server.vhd”

$destContext = New-AzureStorageContext –StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey
Start-AzureStorageBlobCopy -AbsoluteUri $absoluteUri -DestContainer $destContainer -DestContext $destContext -DestBlob $blobName
Get-AzureStorageBlobCopyState -Context $destContext -Blob $blobName -Container vhds