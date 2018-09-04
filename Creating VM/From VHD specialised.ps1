Login-AzureRmAccount
Get-AzureRmSubscription
Select-AzureRmSubscription -Subscription 610e1e34-1260-4e18-9fcf-a751ad54a8ec

$vnetname = "KREPL-Vnet"
$rgName = "KREPL-RG"
$location = "South India"
$vnet = Get-AzureRmVirtualNetwork -Name $vnetname -ResourceGroupName $rgName
#Creating IP 
$ipName = "RDSIP"
$pip = New-AzureRmPublicIpAddress -Name $ipName -ResourceGroupName $rgName -Location $location -AllocationMethod Dynamic
#Creating NIC
$nicName = "WP-NIC"
$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $rgName -Location $location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id

# Set the URI for the VHD that you want to use. In this example, the VHD file named "myOsDisk.vhd" is kept 

$osDiskUri = "https://krishiwpstg.blob.core.windows.net/vhds1/Krishi-WP0120170724230827.vhd"

# Set the VM name and size. This example sets the VM name to "myVM" and the VM size to "Standard_A2".
$Avset = Get-AzureRmAvailabilitySet -ResourceGroupName $rgName -Name "RDS-AVSET"
$vmName = "Krishi-RD2"
$vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize "Standard_D12_v2" -AvailabilitySetId $Avset.Id

# Add the NIC
$vm = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $nic.Id

# Add the OS disk by using the URL of the copied OS VHD. In this example, when the OS disk is created, the 
# term "osDisk" is appened to the VM name to create the OS disk name. This example also specifies that this 
# Windows-based VHD should be attached to the VM as the OS disk.
$osDiskName = $vmName + "osDisk"
$vm = Set-AzureRmVMOSDisk -VM $vm -Name $osDiskName -VhdUri $osDiskUri -CreateOption attach -Windows
#Create the new VM
New-AzureRmVM -ResourceGroupName $rgName -Location $location -VM $vm 