# Sysprep the VM after login 

Login-AzureRmAccount
Get-AzureRmSubscription
Select-AzureRmSubscription -SubscriptionId 4dd2bc4c-f9c4-4f3d-98fc-6f808be8a100
$Rgname = "Custom"
$Vmname = "CustomVM"
$location = "centralindia"
Stop-AzureRmVM -Name $Vmname -Force -ResourceGroupName $Rgname
Set-AzureRmVM -ResourceGroupName $Rgname -Name $Vmname -Generalized
$VM = Get-AzureRmVM -ResourceGroupName $Rgname -Name $Vmname -Status
$VM.Statuses

# create the Image

Save-AzureRmVMImage -Name $Vmname -DestinationContainerName "vhds" -VHDNamePrefix "custom" -ResourceGroupName $Rgname -Path "C:\vmss\custom.json"

# crete VM from Image
$imageURI = "https://customdisk.blob.core.windows.net/system/Microsoft.Compute/Images/vhds/custom-osDisk.bc0aca24-f364-470c-a43b-be6baacdfe74.vhd"

$Rgname = $Rgname
$subnetName = "mySubnet"
$singleSubnet = New-AzureRmVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix 10.0.0.0/24
$location = $location
$vnetName = "myVnet"
$vnet = New-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $Rgname -Location $location -AddressPrefix 10.0.0.0/16 -Subnet $singleSubnet

$ipName = "myPip"
$pip = New-AzureRmPublicIpAddress -Name $ipName -ResourceGroupName $Rgname -Location $location -AllocationMethod Dynamic

$nicName = "myNic"
$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $Rgname -Location $location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id

$nsgName = "myNsg"
$rdpRule = New-AzureRmNetworkSecurityRuleConfig -Name myRdpRule -Description "Allow RDP" -Access Allow -Protocol Tcp -Direction Inbound -Priority 110 -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389

$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $Rgname -Location $location -Name $nsgName -SecurityRules $rdpRule

$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $rgName -Name $vnetName
# Enter a new user name and password to use as the local administrator account 
    # for remotely accessing the VM.
    $cred = Get-Credential

    # Name of the storage account where the VHD is located. This example sets the 
    # storage account name as "myStorageAccount"
    $storageAccName = "customdisk"

    # Name of the virtual machine. This example sets the VM name as "myVM".
    $vmName = "myVM"

    # Size of the virtual machine. This example creates "Standard_D2_v2" sized VM. 
    # See the VM sizes documentation for more information: 
    # https://azure.microsoft.com/documentation/articles/virtual-machines-windows-sizes/
    $vmSize = "Standard_D1_v2"

    # Computer name for the VM. This examples sets the computer name as "myComputer".
    $computerName = "myComputer"

    # Name of the disk that holds the OS. This example sets the 
    # OS disk name as "myOsDisk"
    $osDiskName = "myOsDisk"

    # Assign a SKU name. This example sets the SKU name as "Standard_LRS"
    # Valid values for -SkuName are: Standard_LRS - locally redundant storage, Standard_ZRS - zone redundant
    # storage, Standard_GRS - geo redundant storage, Standard_RAGRS - read access geo redundant storage,
    # Premium_LRS - premium locally redundant storage. 
    $skuName = "Standard_LRS"

    # Get the storage account where the uploaded image is stored
    $storageAcc = Get-AzureRmStorageAccount -ResourceGroupName $Rgname -AccountName $storageAccName

    # Set the VM name and size
    $vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize

    #Set the Windows operating system configuration and add the NIC
    $vm = Set-AzureRmVMOperatingSystem -VM $vmConfig -Windows -ComputerName $computerName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
    $vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id

    # Create the OS disk URI
    $osDiskUri = '{0}vhds/{1}-{2}.vhd' -f $storageAcc.PrimaryEndpoints.Blob.ToString(), $vmName.ToLower(), $osDiskName

    # Configure the OS disk to be created from the existing VHD image (-CreateOption fromImage).
    $vm = Set-AzureRmVMOSDisk -VM $vm -Name $osDiskName -VhdUri $osDiskUri -CreateOption fromImage -SourceImageUri $imageURI -Windows

    # Create the new VM
    New-AzureRmVM -ResourceGroupName $rgName -Location $location -VM $vm