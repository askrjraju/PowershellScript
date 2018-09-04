 # register your Subscription for Multiple IP's
 
Register-AzureRmProviderFeature -FeatureName AllowMultipleIpConfigurationsPerNic -ProviderNamespace Microsoft.Network
Register-AzureRmProviderFeature -FeatureName AllowLoadBalancingonSecondaryIpconfigs -ProviderNamespace Microsoft.Network
Register-AzureRmResourceProvider -ProviderNamespace Microsoft.Network
Get-AzureRmProviderFeature
# Resource Group
 $location = "southindia"
 $rgName = "myResourceGroup"
 New-AzureRmResourceGroup -Name $rgName -Location $location
 # StorageAccount
  $myStorageAccountName = "mymsvmstg02"
 Get-AzureRmStorageAccountNameAvailability $myStorageAccountName
  $myStorageAccount = New-AzureRmStorageAccount -ResourceGroupName $rgName -Name $myStorageAccountName -SkuName "Standard_LRS" -Kind "Storage" -Location $location
  # Create a virtual network
$subnetName = "websubnet"
$SingleSubnet = New-AzureRmVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix 192.168.1.0/24
$vnetName = "Vnet"
$vnet = New-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $Rgname -Location $locName -AddressPrefix 192.168.0.0/16 -Subnet $SingleSubnet

#
 $Subnet = $Vnet.Subnets | Where-Object { $_.Name -eq $SubnetName }

 # IPConfig-1
$myPublicIp1     = New-AzureRmPublicIpAddress -Name "myPublicIp1" -ResourceGroupName $rgName -Location $location -AllocationMethod Static
$IpConfigName1  = "IPConfig-1"
$IpConfig1      = New-AzureRmNetworkInterfaceIpConfig -Name $IpConfigName1 -Subnet $Subnet -PublicIpAddress $myPublicIp1 -Primary
# Ipconfig2
$IpConfigName2 = "IPConfig-2"
$IPAddress     = 192.168.1.5
$myPublicIp2   = New-AzureRmPublicIpAddress -Name "myPublicIp2" -ResourceGroupName $rgName -Location $location -AllocationMethod Static
$IpConfig2     = New-AzureRmNetworkInterfaceIpConfig -Name $IpConfigName2 -Subnet $Subnet -PrivateIpAddress $IPAddress -PublicIpAddress $myPublicIp2
#ipconfig 3
$IpConfigName3 = "IpConfig-3"
$IpConfig3 = New-AzureRmNetworkInterfaceIpConfig -Name $IPConfigName3 -Subnet $Subnet
$myNIC = New-AzureRmNetworkInterface -Name myNIC -ResourceGroupName $rgName -Location $location -IpConfiguration $IpConfig1,$IpConfig2,$IpConfig3

# getstorage account
$stAccount = Get-AzureRmStorageAccount -ResourceGroupName $rgName -Name $myStorageAccountName 

#create a VM
$cred = Get-Credential -Message "lalit nt5.0no!more1"
$VmName = "Atsvm2"
$VM = New-AzureRmVMConfig -VMName $VmName -VMSize Standard_D2_V2
$ComputerName = $VmName
$VM = Set-AzureRmVMOperatingSystem -VM $VM -Windows -ComputerName $VmName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$VM = Set-AzureRmVMSourceImage -VM $VM -PublisherName MicrosoftWindowsServer -Offer WIndowsServer -Skus 2012-R2-Datacenter -Version "latest"
$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $myNIC.Id
$blobpath = "vhds/windowsVmOsDisk.vhd"
$osDiskuri = $stAccount.PrimaryEndpoints.Blob.ToString() + $blobpath
$diskName = "MyVmOsDisk"
$vm = Set-AzureRmVMOSDisk -Name $diskName -VM $vm -VhdUri $osDiskuri -Caching ReadWrite -CreateOption FromImage
New-AzureRmVM -ResourceGroupName $Rgname -Location $locName -VM $VM

