Login-AzureRmAccount
Get-AzureRmSubscription
Select-AzureRmSubscription -SubscriptionId c1aad7a4-2156-41c1-ad9a-8268e218818c
$rgname = "CLEXAZ-RG"
$location = "SouthIndia"
$vnetName = "CLEXAZ-VNET"

#Express Route gateway
$vnet = Get-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $rgname
$gwSubnet = Get-AzureRmVirtualNetworkSubnetConfig -Name "GatewaySubnet" -VirtualNetwork $vnet
$gwIP = New-AzureRmPublicIpAddress -Name "ERGatewayIP" -ResourceGroupName $rgname -Location $location -AllocationMethod Dynamic
$gwConfig = New-AzureRmVirtualNetworkGatewayIpConfig -Name "ERGatewayIpConfig" -SubnetId $gwSubnet.Id -PublicIpAddressId $gwIP.Id
$gw = New-AzureRmVirtualNetworkGateway -Name "CLEX_ERGateway" -ResourceGroupName $rgname -Location $location -IpConfigurations $gwConfig -GatewayType "ExpressRoute" -GatewaySku Standard

#VPN Gateway
$gwSubnet = Get-AzureRmVirtualNetworkSubnetConfig -Name "GatewaySubnet" -VirtualNetwork $vnet
$vpngwIP = Get-AzureRmPublicIpAddress -Name "VPNGTW_PIP" -ResourceGroupName "NET_RSG"
$vpngwConfig = New-AzureRmVirtualNetworkGatewayIpConfig -Name "VPNGTWIPConfig" -SubnetId $gwSubnet.Id -PublicIpAddressId $vpngwIP.Id
$gtw1 = New-AzureRmVirtualNetworkGateway -Name "SNL_VNETGW1" -ResourceGroupName "NET_RSG" -Location "South India" -IpConfigurations $vpngwConfig -GatewayType "Vpn" -VpnType "RouteBased" -GatewaySku "Standard"


