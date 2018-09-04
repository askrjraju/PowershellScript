#Create variables
# Enter a new user name and password to use as the local administrator account for the remotely accessing the VM
$cred = Get-Credential
$rgname = "nucleus-prod"
$location = "southeastasia"
$urlOfUploadedImageVhd = "https://nucleusstd.blob.core.windows.net/vhds/raw_vhd.vhd"

$ipName = "TempPubIP1"

$pip = New-AzureRmPublicIpAddress -Name $ipName -ResourceGroupName $rgName -Location $location -AllocationMethod Dynamic

$nicName = "Tempnic1"

$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $rgName -Location $location -SubnetId "/subscriptions/a95e6c8b-571e-4664-a2e7-b01f7bce7ef7/resourceGroups/Nucleus-Prod/providers/Microsoft.Network/virtualNetworks/Nucleus-Vnet1/subnets/Subnet-1" -PublicIpAddressId $pip.Id

#"/subscriptions/cf9cfe99-c3f5-43f4-a69a-3ea2f22b8774/resourceGroups/firstprodrg/providers/Microsoft.Network/virtualNetworks/firstProdrg-vnet/subnets/default" -PublicIpAddressId $pip.Id



# Name of the storage account where the VHD file is and where the OS disk will be created
$storageAccName = "nucleusstd"

# Name of the virtual machine
$vmName = "newtempVM"

# Size of the virtual machine. See the VM sizes documentation for more information: https://azure.microsoft.com/documentation/articles/virtual-machines-windows-sizes/
$vmSize = "Standard_DS1_V2"

# Computer name for the VM
$computerName = "newtempVM"

# Name of the disk that holds the OS
$osDiskName = "myOSDisk"

#Get the storage account where the uploaded image is stored
$storageAcc = Get-AzureRmStorageAccount -ResourceGroupName $rgName -AccountName $storageAccName

#Set the VM name and size
#Use "Get-Help New-AzureRmVMConfig" to know the available options for -VMsize
$vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize

#Set the Windows operating system configuration and add the NIC
$vm = Set-AzureRmVMOperatingSystem -VM $vmConfig -Windows -ComputerName $computerName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate

$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id

#Create the OS disk URI
$osDiskUri = $urlOfUploadedImageVhd
# $osDiskUri = '{0}vhds/{1}-{2}.vhd' -f $storageAcc.PrimaryEndpoints.Blob.ToString(), $vmName.ToLower(), $osDiskName

#Configure the OS disk to be created from the image (-CreateOption fromImage), and give the URL of the uploaded image VHD for the -SourceImageUri parameter
#You set this variable when you uploaded the VHD
$vm = Set-AzureRmVMOSDisk -VM $vm -Name $osDiskName -VhdUri $osDiskUri -CreateOption Attach -Caching ReadWrite -Windows

#Create the new VM
New-AzureRmVM -ResourceGroupName $rgName -Location $location -VM $vm