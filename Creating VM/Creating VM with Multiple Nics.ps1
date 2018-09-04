Login-AzureRmAccount
Get-AzureRmSubscription
$rgname = "TestRG"
$location = "southindia"
New-AzureRmResourceGroup -Name $rgname -Location $location

$stname = "dlvstg02"
$staccount = New-AzureRmStorageAccount -Name $stname -ResourceGroupName $rgname -SkuName Standard_LRS -Location $location -Kind Storage 

$subnet1name = "Frontend"
$subnet2name = "Backend"
$subnet1 = New-AzureRmVirtualNetworkSubnetConfig -Name $subnet1name -AddressPrefix 192.168.1.0/24
$subnet2 = New-AzureRmVirtualNetworkSubnetConfig -Name $subnet2name -AddressPrefix 192.168.2.0/24

$vnetname = "TestVnet"
$vnet = New-AzureRmVirtualNetwork -Name $vnetname -ResourceGroupName $rgname -Location $location -AddressPrefix 192.168.0.0/16 -Subnet $subnet1,$subnet2

$frontend = $vnet.Subnets |? {$_.Name -eq $subnet1name}
$backend = $vnet.Subnets | ? {$_.Name -eq $subnet2name}

$nic1name = "Frontendnic"
$nic2name = "Backendnic"

$nic1 = New-AzureRmNetworkInterface -Name $nic1name -ResourceGroupName $rgname -Location $location -SubnetId $frontend.Id
$nic2 = New-AzureRmNetworkInterface -Name $nic2name -ResourceGroupName $rgname -Location $location -SubnetId $backend.Id 

$cred = Get-Credential
$VmName = "Atsvm2"
$VM = New-AzureRmVMConfig -VMName "AtsVM" -VMSize Standard_D2_V2
$ComputerName = $VmName
$VM = Set-AzureRmVMOperatingSystem -VM $VM -Windows -ComputerName $VmName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$VM = Set-AzureRmVMSourceImage -VM $VM -PublisherName MicrosoftWindowsServer -Offer WIndowsServer -Skus 2012-R2-Datacenter -Version "latest"
$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic1.Id -Primary
$Vm = Add-AzureRmVMNetworkInterface -VM $VM -Id $nic2.Id
$blobpath = "vhds/windowsVmOsDisk.vhd"
$osDiskuri = $staccount.PrimaryEndpoints.Blob.ToString() + $blobpath
$diskName = "MyVmOsDisk"
$vm = Set-AzureRmVMOSDisk -Name $diskName -VM $vm -VhdUri $osDiskuri -Caching ReadWrite -CreateOption FromImage
New-AzureRmVM -ResourceGroupName $Rgname -Location $location -VM $VM