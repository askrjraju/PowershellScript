Login-AzureRmAccount
Get-AzureRmSubscription
Select-AzureRmSubscription -SubscriptionId 4dd2bc4c-f9c4-4f3d-98fc-6f808be8a100
$Rgname = "TestRG"
$vmname = "Test"
$location = "CentralIndia"
# Generalized the VM
Stop-AzureRmVM -ResourceGroupName $Rgname -Name $vmname -Force
Set-AzureRmVM -ResourceGroupName $Rgname -Name $vmname -Generalized
$VM = Get-AzureRmVM -ResourceGroupName $Rgname -Name $vmname -Status
$vm.Statuses

#Creare the Image
$VM = Get-AzureRmVM -ResourceGroupName $Rgname -Name $vmname
$image = New-AzureRmImageConfig -Location EastUS -SourceVirtualMachineId $vm.Id
New-AzureRmImage -Image $image -ImageName "myImage" -ResourceGroupName myResourceGroupImages

# Create VM from Image

$cred = Get-Credential -Message "Lalit 123@mail.com"

# For New Resource Group
New-AzureRmResourceGroup -Name "RGNAME" -Location "LOCNAME"
# for Existing Resource group
$RG = Get-AzureRmResourceGroup -Name $Rgname -Location $location

# For New VIrtual Network
$subnetConfig = New-AzureRmVirtualNetworkSubnetConfig -Name mySubnet -AddressPrefix 192.168.1.0/24
$vnet = New-AzureRmVirtualNetwork -ResourceGroupName myResourceGroupFromImage -Location EastUS -Name MYvNET -AddressPrefix 192.168.0.0/16 -Subnet $subnetConfig

# for existing Vnet
$vnetName = "TestRG-vnet"
$Vnet = Get-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $Rgname 


$pip = New-AzureRmPublicIpAddress -ResourceGroupName $Rgname -Location $location -Name "myIp" -AllocationMethod Dynamic

$nsgRuleRDP = New-AzureRmNetworkSecurityRuleConfig -Name "AllowRDP" -Protocol Tcp -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389 -Access Allow

  $nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $Rgname -Location $location -Name "mYnsg" -SecurityRules $nsgRuleRDP

$nic = New-AzureRmNetworkInterface -Name myNic -ResourceGroupName $Rgname -Location $location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id

$vmConfig = New-AzureRmVMConfig -VMName myVMfromImage -VMSize Standard_D1_V2 | Set-AzureRmVMOperatingSystem -Windows -ComputerName myComputer -Credential $cred 

# Here is where we create a variable to store information about the image 
$image = Get-AzureRmImage -ImageName "MyImage" -ResourceGroupName $Rgname

# Here is where we specify that we want to create the VM from and image and provide the image ID
$vmConfig = Set-AzureRmVMSourceImage -VM $vmConfig -Id $image.Id

$vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $nic.Id

New-AzureRmVM -ResourceGroupName $Rgname -Location $location -VM $vmConfig

