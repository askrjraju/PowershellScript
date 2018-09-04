Login-AzureRmAccount
Get-AzureRmSubscription
Select-AzureRmSubscription -SubscriptionId f77a199a-9dcf-426e-a0ec-4ecafad80016

    $location = "South India" 
    
    $vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $rgName -Name Testvnet


    #IP
 $ipName = "myPip"
     $pip = New-AzureRmPublicIpAddress -Name $ipName -ResourceGroupName $rgName -Location $location -AllocationMethod Dynamic

     #NIC
$nicName = "myNic"
$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $rgName -Location $location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id


#Resource Group name
$rgName = "UploadVMrg"
    
    # Enter a new user name and password to use as the local administrator account 
    # for remotely accessing the VM.
     $cred = Get-Credential -Message "lalit 123@mail.com"

    # Name of the storage account where the VHD is located. This example sets the 
    # storage account name as "myStorageAccount"
    $storageAccName = "msvmstg"

    # Name of the virtual machine. This example sets the VM name as "myVM".
    $vmName = "centosvm"

    # Size of the virtual machine. This example creates "Standard_D2_v2" sized VM. 
    # See the VM sizes documentation for more information: 
    # https://azure.microsoft.com/documentation/articles/virtual-machines-windows-sizes/
    $vmSize = "Standard_D1_v2"

    # Computer name for the VM. This examples sets the computer name as "myComputer".
    $computerName = "centosvm"

    # Name of the disk that holds the OS. This example sets the 
    # OS disk name as "myOsDisk"
    $osDiskName = "myOsDisk"

    # Assign a SKU name. This example sets the SKU name as "Standard_LRS"
    # Valid values for -SkuName are: Standard_LRS - locally redundant storage, Standard_ZRS - zone redundant
    # storage, Standard_GRS - geo redundant storage, Standard_RAGRS - read access geo redundant storage,
    # Premium_LRS - premium locally redundant storage. 
    $skuName = "Standard_LRS"

    # Get the storage account where the uploaded image is stored
    $storageAcc = Get-AzureRmStorageAccount -ResourceGroupName $rgName -Name $storageAccName

    # Set the VM name and size
    $vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize

    #Set the Windows operating system configuration and add the NIC
    $vm = Set-AzureRmVMOperatingSystem -VM $vmConfig -Linux -ComputerName $computerName -Credential $cred
    $vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id
    $storageAcc 
    # Create the OS disk URI
    $osDiskUri = '{0}vhds/{1}-{2}.vhd'-f $storageAcc.PrimaryEndpoints.Blob.ToString(), $vmName.ToLower(), $osDiskName
    # Image URi
    $imageURI = "https://msvmstg.blob.core.windows.net/vhds/CentOSDisk.vhd"

    # Configure the OS disk to be created from the existing VHD image (-CreateOption fromImage).
    $vm = Set-AzureRmVMOSDisk -VM $vm -Name $osDiskName -VhdUri $osDiskUri -CreateOption fromImage -SourceImageUri $imageURI -Linux

    # Create the new VM
    New-AzureRmVM -ResourceGroupName $rgName -Location $location -VM $vm 


