# Add NSG 
$NSG = New-AzureRmNetworkSecurityGroup -Name "ADDS_NSG" -ResourceGroupName $rgname -Location $Location 
$NSG = New-AzureRmNetworkSecurityGroup -Name "WAP_NSG" -ResourceGroupName $rgname -Location $Location
# Assigned NSG to Subnet
$vnet = Get-AzureRmVirtualNetwork -Name "VNET" -ResourceGroupName $rgname 
$Subnet = $vnet.Subnets | Where-Object {$_.Name -eq "Backend"}
Set-AzureRmVirtualNetworkSubnetConfig -Name "Backend" -VirtualNetwork $vnet -AddressPrefix $Subnet.AddressPrefix -NetworkSecurityGroup $NSG
Set-AzureRmVirtualNetwork -VirtualNetwork $vnet -Verbose

# remove NSG associatino from Subnet 
$vnet = Get-AzureRmVirtualNetwork | Where-Object {$_.ResourceGroupName -eq "DLVRG"}
$Subnet = $vnet.Subnets | Where-Object {$_.Name -eq "Backend"} 
$Subnet.NetworkSecurityGroup = $null
Set-AzureRmVirtualNetwork -VirtualNetwork $vnet 