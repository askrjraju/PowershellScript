Add-AzureAccount
Get-AzureSubscription
Select-AzureSubscription -SubscriptionId e778d4ff-7299-4e02-90ff-a7e23c326f20
Set-AzureVNetGatewayKey -VNetName "centralvnet" -LocalNetworkSiteName "onpremsouth" -SharedKey "a1b2c3"
Set-AzureVNetGatewayKey -VNetName "southvnet" -LocalNetworkSiteName "onpremcentral" -SharedKey "a1b2c3"

# New Portal Site to site
Login-AzureRmAccount
 Add-AzureAccount
 Get-AzureVNetConfig -ExportToFile C:\AzureNet\NetworkConfig.xml

 Set-AzureVNetGatewayKey -VNetName "centralvnet" -LocalNetworkSiteName "FBABBBC4_onpremeast" -SharedKey "a1b2c3"
 #Create the VPN connection by running the following commands:
  $vnet01gateway = Get-AzureRMLocalNetworkGateway -Name onpremcent -ResourceGroupName SoutheastRG
 $vnet02gateway = Get-AzureRmVirtualNetworkGateway -Name southeastGW -ResourceGroupName SoutheastRG

  New-AzureRmVirtualNetworkGatewayConnection -Name easttocent -ResourceGroupName SoutheastRG `
 -Location "southeastasia" -VirtualNetworkGateway1 `
 $vnet02gateway -LocalNetworkGateway2 `
 $vnet01gateway -ConnectionType IPsec -RoutingWeight 10 -SharedKey 'abc123'

