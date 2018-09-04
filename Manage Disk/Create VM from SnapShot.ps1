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

# Crete VM from Managed Disk
$rgName = "ManageDiskRG"
$location = "southindia"
$vnet = "Test-vnet"
$subnet = "/subscriptions/cd99a887-4dcd-42d6-b6b3-85a7aabe9c02/resourceGroups/ManageDiskRG/providers/Microsoft.Network/virtualNetworks/Test-Vnet/subnets/default"
$nicName = "VM01-Nic-01"
$vmName = "VM01"
$osDiskName = "VM01-OSDisk"
$osDiskUri = "https://mdiskst.blob.core.windows.net/vhds/server.vhd"
$VMSize = "Standard_A1"
$storageAccountType = "StandardLRS"
$IPaddress = "10.3.0.6"

#Create the VM resources
$IPconfig = New-AzureRmNetworkInterfaceIpConfig -Name "IPConfig1" -PrivateIpAddressVersion IPv4 -PrivateIpAddress $IPaddress -SubnetId $subnet
$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $rgName -Location $location -IpConfiguration $IPconfig
$vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize $VMSize
$vm = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $nic.Id

$osDisk = New-AzureRmDisk -DiskName $osDiskName -Disk (New-AzureRmDiskConfig -AccountType $storageAccountType -Location $location -CreateOption Import -SourceUri $osDiskUri) -ResourceGroupName $rgName
$vm = Set-AzureRmVMOSDisk -VM $vm -ManagedDiskId $osDisk.Id -StorageAccountType $storageAccountType -DiskSizeInGB 128 -CreateOption Attach -Windows
$vm = Set-AzureRmVMBootDiagnostics -VM $vm -disable

#Create the new VM
New-AzureRmVM -ResourceGroupName $rgName -Location $location -VM $vm