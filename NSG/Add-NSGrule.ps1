Login-AzureRmAccount
# remove-RSGRULE
Get-AzureRmNetworkSecurityGroup -Name UNFP_NSG -ResourceGroupName UNIFY_RSG | Remove-AzureRmNetworkSecurityRuleConfig -Name "HTTPS" | Set-AzureRmNetworkSecurityGroup

# Add - NSG RULE
Get-AzurermNetworkSecurityGroup -Name UNFP_NSG -ResourceGroupName UNIFY_RSG | Add-AzurermNetworkSecurityRuleConfig -Name "CPANEL-HTTP-TCP" -Direction Inbound -Priority 110 -Access Allow -SourceAddressPrefix '*'  -SourcePortRange '80' -DestinationAddressPrefix '*' -DestinationPortRange '80' -Protocol 'TCP' | Set-AzurermNetworkSecurityGroup
$NSG = Get-AzurermNetworkSecurityGroup -Name UNFP_NSG -ResourceGroupName UNIFY_RSG
$NSG | Add-AzurermNetworkSecurityRuleConfig -Name "CPANEL-HTTPS-TCP" -Direction Inbound -Priority 130 -Access Allow -SourceAddressPrefix '*'  -SourcePortRange '443' -DestinationAddressPrefix '*' -DestinationPortRange '443' -Protocol 'TCP' | Set-AzurermNetworkSecurityGroup
$NSG | Add-AzurermNetworkSecurityRuleConfig -Name "CPANEL-HTTPS-UDP" -Direction Inbound -Priority 140 -Access Allow -SourceAddressPrefix '*'  -SourcePortRange '443' -DestinationAddressPrefix '*' -DestinationPortRange '443' -Protocol 'UDP' | Set-AzurermNetworkSecurityGroup
$NSG | Add-AzurermNetworkSecurityRuleConfig -Name "CPANEL-2082-TCP" -Direction Inbound -Priority 150 -Access Allow -SourceAddressPrefix '*'  -SourcePortRange '2082' -DestinationAddressPrefix '*' -DestinationPortRange '2082' -Protocol 'TCP' | Set-AzurermNetworkSecurityGroup
$NSG | Add-AzurermNetworkSecurityRuleConfig -Name "CPANEL-2082-UDP" -Direction Inbound -Priority 160 -Access Allow -SourceAddressPrefix '*'  -SourcePortRange '2082' -DestinationAddressPrefix '*' -DestinationPortRange '2082' -Protocol 'UDP' | Set-AzurermNetworkSecurityGroup
$NSG | Add-AzurermNetworkSecurityRuleConfig -Name "CPANEL-2083-TCP" -Direction Inbound -Priority 170 -Access Allow -SourceAddressPrefix '*'  -SourcePortRange '2083' -DestinationAddressPrefix '*' -DestinationPortRange '2083' -Protocol 'TCP' | Set-AzurermNetworkSecurityGroup
$NSG | Add-AzurermNetworkSecurityRuleConfig -Name "CPANEL-2083-UDP" -Direction Inbound -Priority 180 -Access Allow -SourceAddressPrefix '*'  -SourcePortRange '2083' -DestinationAddressPrefix '*' -DestinationPortRange '2083' -Protocol 'UDP' | Set-AzurermNetworkSecurityGroup
$NSG | Add-AzurermNetworkSecurityRuleConfig -Name "CPANEL-2086-TCP" -Direction Inbound -Priority 190 -Access Allow -SourceAddressPrefix '*'  -SourcePortRange '2086' -DestinationAddressPrefix '*' -DestinationPortRange '2086' -Protocol 'TCP' | Set-AzurermNetworkSecurityGroup
$NSG | Add-AzurermNetworkSecurityRuleConfig -Name "CPANEL-2086-UDP" -Direction Inbound -Priority 200 -Access Allow -SourceAddressPrefix '*'  -SourcePortRange '2086' -DestinationAddressPrefix '*' -DestinationPortRange '2086' -Protocol 'UDP' | Set-AzurermNetworkSecurityGroup
$NSG | Add-AzurermNetworkSecurityRuleConfig -Name "CPANEL-2096-TCP" -Direction Inbound -Priority 250 -Access Allow -SourceAddressPrefix '*'  -SourcePortRange '2096' -DestinationAddressPrefix '*' -DestinationPortRange '2096' -Protocol 'TCP' | Set-AzurermNetworkSecurityGroup
$NSG | Add-AzurermNetworkSecurityRuleConfig -Name "CPANEL-2096-UDP" -Direction Inbound -Priority 260 -Access Allow -SourceAddressPrefix '*'  -SourcePortRange '2096' -DestinationAddressPrefix '*' -DestinationPortRange '2096' -Protocol 'UDP' | Set-AzurermNetworkSecurityGroup
