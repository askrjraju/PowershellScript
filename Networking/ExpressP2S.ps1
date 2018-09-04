$vnetname = "CLEXAZ-VNET"
$rgname = "CLEXAZ-RG"
$location = "southIndia"

$vnet = Get-AzureRmVirtualNetwork -Name $vnetname -ResourceGroupName $rgname
$gwSubnet = Get-AzureRmVirtualNetworkSubnetConfig -Name "GatewaySubnet" -VirtualNetwork $vnet
$gwIP = New-AzureRmPublicIpAddress -Name "P2SGatewayIP" -ResourceGroupName $rgname -Location $location -AllocationMethod Dynamic
$gwConfig = New-AzureRmVirtualNetworkGatewayIpConfig -Name "P2SGatewayIpConfig" -SubnetId $gwSubnet.Id -PublicIpAddressId $gwIP.Id
New-AzureRmVirtualNetworkGateway -Name "ClexP2s-Gateway" -ResourceGroupName $rgname -Location $location -IpConfigurations $gwConfig -GatewayType "Vpn" -VpnType "RouteBased" -GatewaySku "Standard"