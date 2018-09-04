$locName = "Southindia"
$Rgname = "TestRG"
$stName = "linuxvmstg01"
New-AzureRmResourceGroup -Name $Rgname -Location $locName
$stAccount = New-AzureRmStorageAccount -Name $stName -ResourceGroupName $Rgname -SkuName Standard_LRS -Location $locName -Kind Storage
$subnetName = "websubnet"
$SingleSubnet = New-AzureRmVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix 192.168.1.0/24
$vnetName = "Vnet"
$vnet = New-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $Rgname -Location $locName -AddressPrefix 192.168.0.0/16 -Subnet $SingleSubnet
$IPName = "MYVMIP"
$Pip = New-AzureRmPublicIpAddress -Name $IPName -ResourceGroupName $Rgname -Location $locName -AllocationMethod Dynamic
$NicName = "MYVMNIC"
$Nic = New-AzureRmNetworkInterface -Name $NicName -ResourceGroupName $Rgname -Location $locName -SubnetId $vnet.Subnets[0].id -PublicIpAddressId $pip.Id
$cred = Get-Credential -Message "lalit nt5.0no!more1"
$VmName = "LinuxVm"
$VM = New-AzureRmVMConfig -VMName $VmName -VMSize Standard_D2_V2
$ComputerName = $VmName
$VM = Set-AzureRmVMOperatingSystem -VM $VM -Windows -ComputerName $VmName -Credential $cred
$VM = Set-AzureRmVMSourceImage -VM $VM -PublisherName OpenLogic -Offer CentOS -Skus 7.2 -Version "latest"
$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $Nic.Id
$blobpath = "vhds/linuxVmOsDisk.vhd"
$osDiskuri = $stAccount.PrimaryEndpoints.Blob.ToString() + $blobpath
$diskName = "MyVmOsDisk"
$vm = Set-AzureRmVMOSDisk -Name $diskName -VM $vm -VhdUri $osDiskuri -Caching ReadWrite -CreateOption FromImage
New-AzureRmVM -ResourceGroupName $Rgname -Location $locName -VM $VM
