# Add Subnet
$vnet = Get-AzureRmVirtualNetwork -Name "Vnet" -ResourceGroupName $rgname 
Add-AzureRmVirtualNetworkSubnetConfig -Name "Frontend" -VirtualNetwork $vnet -AddressPrefix 192.168.1.0/27 
Set-AzureRmVirtualNetwork -VirtualNetwork $vnet 