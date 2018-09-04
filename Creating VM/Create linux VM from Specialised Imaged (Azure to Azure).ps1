Login-AzureRmAccount
Get-AzureRmSubscription

$vnetname = "Testvnet"
$rgName = "UploadVMrg"
$location = "South India"
$vnet = Get-AzureRmVirtualNetwork -Name $vnetname -ResourceGroupName $rgName
#Creating IP 
$ipName = "myIP"
$pip = New-AzureRmPublicIpAddress -Name $ipName -ResourceGroupName $rgName -Location $location -AllocationMethod Dynamic
#Creating NIC
$nicName = "myNic"
$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $rgName -Location $location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id

# for existing Nic
$nicName = "myNic"
$nic1 = Get-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $rgName 

# Set the URI for the VHD that you want to use. In this example, the VHD file named "myOsDisk.vhd" is kept 

$osDiskUri = "https://msvmstg.blob.core.windows.net/vhds/centosvm-myOsDisk.vhd"

# Set the VM name and size. This example sets the VM name to "myVM" and the VM size to "Standard_A2".
$vmName = "AZR-ADFS01-SVR"
$vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize "Standard_A2"

# Add the NIC
$vm = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $nic1.Id

# Add the OS disk by using the URL of the copied OS VHD. In this example, when the OS disk is created, the 
# term "osDisk" is appened to the VM name to create the OS disk name. This example also specifies that this 
# Windows-based VHD should be attached to the VM as the OS disk.
$osDiskName = $vmName + "osDisk"
$vm = Set-AzureRmVMOSDisk -VM $vm -Name $osDiskName -VhdUri $osDiskUri -CreateOption attach -Linux
#Create the new VM
New-AzureRmVM -ResourceGroupName $rgName -Location $location -VM $vm
