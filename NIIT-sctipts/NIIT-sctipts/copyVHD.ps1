Select-AzureSubscription -subscriptionId "cf9cfe99-c3f5-43f4-a69a-3ea2f22b8774"  
 
### Source VHD - anonymous access container ###
$srcUri = "https://generalstorageudhay.blob.core.windows.net/vhds/generalVM2016815173025.vhd" 
 
### Target Storage Account ###
$storageAccount = "premstorageudhay"
$storageKey = "gzujGeSQ6MLuBEYYErM6+/szsi3OjU610lM0IL4nJbefYc6YQoUDwaZMYDTzWDJ2Ky0aIkoZMsHoJONgU6CuuA=="
 
### Create the destination context for authenticating the copy
$destContext = New-AzureStorageContext  –StorageAccountName $storageAccount `
                                        -StorageAccountKey $storageKey  
 
### Target Container Name
$containerName = "newvhd"
 
### Create the target container in storage
New-AzureStorageContainer -Name $containerName -Context $destContext 
 
### Start the Asynchronous Copy ###
$blob1 = Start-AzureStorageBlobCopy -srcUri $srcUri `
                                    -DestContainer $containerName `
                                    -DestBlob "newcopy1.vhd" `
                                    -DestContext $destContext






