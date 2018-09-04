$rule1 = New-AzureRmNetworkSecurityRuleConfig -Name rdp-rule -Description "Allow RDP" -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389
$rule2 = New-AzureRmNetworkSecurityRuleConfig -Name "CropInsurace" -Description "CropInsurace" -Access Allow -Protocol Tcp -Direction Inbound -Priority 101 -SourceAddressPrefix * -SourcePortRange "8080" -DestinationAddressPrefix * -DestinationPortRange "8080"
$rule3 = New-AzureRmNetworkSecurityRuleConfig -Name "EvidensRs" -Description "EvidensRs" -Access Allow -Protocol Tcp -Direction Inbound -Priority 102 -SourceAddressPrefix * -SourcePortRange "8050" -DestinationAddressPrefix * -DestinationPortRange "8050"
$rule4 = New-AzureRmNetworkSecurityRuleConfig -Name "evidensrs443" -Description "evidensrs443" -Access Allow -Protocol Tcp -Direction Inbound -Priority 103 -SourceAddressPrefix * -SourcePortRange "443" -DestinationAddressPrefix * -DestinationPortRange "443"
$rule5 = New-AzureRmNetworkSecurityRuleConfig -Name "EvidensRSAPI" -Description "EvidensRSAPI" -Access Allow -Protocol Tcp -Direction Inbound -Priority 104 -SourceAddressPrefix * -SourcePortRange "8094" -DestinationAddressPrefix * -DestinationPortRange "8094"
$rule6 = New-AzureRmNetworkSecurityRuleConfig -Name "EvidensRSSer" -Description "EvidensRSSer" -Access Allow -Protocol Tcp -Direction Inbound -Priority 105 -SourceAddressPrefix * -SourcePortRange "8051" -DestinationAddressPrefix * -DestinationPortRange "8051"
$rule7 = New-AzureRmNetworkSecurityRuleConfig -Name "MedSync" -Description "MedSync" -Access Allow -Protocol Tcp -Direction Inbound -Priority 106 -SourceAddressPrefix * -SourcePortRange "8060" -DestinationAddressPrefix * -DestinationPortRange "8060"
$rule8 = New-AzureRmNetworkSecurityRuleConfig -Name "MotoSync" -Description "MotoSync" -Access Allow -Protocol Tcp -Direction Inbound -Priority 107 -SourceAddressPrefix * -SourcePortRange "8070" -DestinationAddressPrefix * -DestinationPortRange "8070"
$rule9 = New-AzureRmNetworkSecurityRuleConfig -Name "RemoteDesktop" -Description "RemoteDesktop" -Access Allow -Protocol Tcp -Direction Inbound -Priority 108 -SourceAddressPrefix * -SourcePortRange "6497" -DestinationAddressPrefix * -DestinationPortRange "3389"
$rule10 = New-AzureRmNetworkSecurityRuleConfig -Name "weatherbank" -Description "weatherbank" -Access Allow -Protocol Tcp -Direction Inbound -Priority 109 -SourceAddressPrefix * -SourcePortRange "3030" -DestinationAddressPrefix * -DestinationPortRange "3030"
$rule10 = New-AzureRmNetworkSecurityRuleConfig -Name "weatherservice" -Description "weatherservice" -Access Allow -Protocol Tcp -Direction Inbound -Priority 110 -SourceAddressPrefix * -SourcePortRange "8091" -DestinationAddressPrefix * -DestinationPortRange "8091"
$rule11 = New-AzureRmNetworkSecurityRuleConfig -Name "WeatInsurance" -Description "WeatInsurance" -Access Allow -Protocol Tcp -Direction Inbound -Priority 111 -SourceAddressPrefix * -SourcePortRange "8090" -DestinationAddressPrefix * -DestinationPortRange "8090"

$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName "TestRG" -Location "SouthIndia" -Name "NSG-FrontEnd" -SecurityRules $rule1,$rule2,$rule3,$rule4,$rule5,$rule6,$rule7,$rule8,$rule9

$RGName = "TestRG"

$NSG = Get-AzureRmNetworkSecurityGroup -Name "NSG-FrontEnd" -ResourceGroupName $RGName

#Add rule to existing to allow RDP 
Add-AzureRmNetworkSecurityRuleConfig -NetworkSecurityGroup $NSG -Name 'RDP' -Direction Inbound -Priority 101 `
    -Access Allow -SourceAddressPrefix 'INTERNET' -SourcePortRange '*' `
    -DestinationAddressPrefix '*' -DestinationPortRange '3389' -Protocol TCP
Set-AzureRmNetworkSecurityGroup -NetworkSecurityGroup $NSG #Apply the change to the in memory object

#Remove a rule
Get-AzurermNetworkSecurityGroup -Name "NSGFrontEnd" -ResourceGroupName $RGName | 
    Remove-AzureRmNetworkSecurityRuleConfig -Name 'RDP' |
    Set-AzureRmNetworkSecurityGroup

#NSG must be same region as the resource
#Associate a NSG to a Virtual machine NIC
$NICName = 'myNicName'
$NIC = Get-AzureRmNetworkInterface -Name $NICName -ResourceGroupName $RGname
$NIC.NetworkSecurityGroup = $NSG
Set-AzureRmNetworkInterface -NetworkInterface $NIC

#Remove a NSG from a VM NIC
$NIC.NetworkSecurityGroup = $null
Set-AzureRmNetworkInterface -NetworkInterface $NIC

#Associate a NSG to a subnet
$VNetName = 'TestVnet'
$RgName = 'TestRG"'
$SubnetNm = 'default'
$VNET = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName  | Set-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $VNET -Name $SubnetNm -AddressPrefix 10.0.2.0/24 -NetworkSecurityGroup $NSG | Set-AzureRmVirtualNetwork -VirtualNetwork $VNET

#Remove a NSG from the subnet
$VNET = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $VNetRG
$VNSubnet = Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $VNET -Name $SubnetNm
$VNSubnet.NetworkSecurityGroup = $null
Set-AzureRmVirtualNetwork -VirtualNetwork $VNET

#Delete a NSG
Remove-AzureRmNetworkSecurityGroup -Name "NSGFrontEnd" -ResourceGroupName $RGName

