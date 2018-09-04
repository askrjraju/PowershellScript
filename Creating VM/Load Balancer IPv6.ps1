Login-AzureRmAccount
Get-AzureRmSubscription
Select-AzureRmSubscription -SubscriptionId b283731d-9959-42eb-aa2a-432935b83f85
$rgname = "TestRg"
$locname = "centralindia"
#Create a resource group
New-AzureRmResourceGroup -Name $rgname -location $locname
#Create a virtual network with a subnet
$backendSubnet = New-AzureRmVirtualNetworkSubnetConfig -Name LB-Subnet-BE -AddressPrefi 192.168.1.0/24
$vnet = New-AzureRmvirtualNetwork -Name VNet -ResourceGroupName $rgname -Location $locname -AddressPrefix 192.168.0.0/16 -Subnet $backendSubnet
#Create Azure Public IP address (PIP) resources for the front-end IP address pool.
$publicIPv4 = New-AzureRmPublicIpAddress -Name 'pub-ipv4' -ResourceGroupName $rgname -Location $locname -AllocationMethod Static -IpAddressVersion IPv4 -DomainNameLabel clbnrpipv4
$publicIPv6 = New-AzureRmPublicIpAddress -Name 'pub-ipv6' -ResourceGroupName $rgname -Location $locname -AllocationMethod Dynamic -IpAddressVersion IPv6 -DomainNameLabel clbnrpipv6
#Create front-end address configuration that uses the Public IP addresses you created
$FEIPConfigv4 = New-AzureRmLoadBalancerFrontendIpConfig -Name "LB-Frontendv4" -PublicIpAddress $publicIPv4
$FEIPConfigv6 = New-AzureRmLoadBalancerFrontendIpConfig -Name "LB-Frontendv6" -PublicIpAddress $publicIPv6
#Create back-end address pools
$backendpoolipv4 = New-AzureRmLoadBalancerBackendAddressPoolConfig -Name "BackendPoolIPv4"
$backendpoolipv6 = New-AzureRmLoadBalancerBackendAddressPoolConfig -Name "BackendPoolIPv6"
#Create the NAT rules
$inboundNATRule1v4 = New-AzureRmLoadBalancerInboundNatRuleConfig -Name "NicNatRulev4" -FrontendIpConfiguration $FEIPConfigv4 -Protocol TCP -FrontendPort 443 -BackendPort 4443
$inboundNATRule1v6 = New-AzureRmLoadBalancerInboundNatRuleConfig -Name "NicNatRulev6" -FrontendIpConfiguration $FEIPConfigv6 -Protocol TCP -FrontendPort 443 -BackendPort 4443
#Create a health probe. There are two ways to configure a probe:HTTP probe
$healthProbe = New-AzureRmLoadBalancerProbeConfig -Name 'HealthProbe-v4v6' -RequestPath 'HealthProbe.aspx' -Protocol http -Port 80 -IntervalInSeconds 15 -ProbeCount 2
#TCP probe
$healthProbe = New-AzureRmLoadBalancerProbeConfig -Name 'HealthProbe-v4v6' -Protocol Tcp -Port 8080 -IntervalInSeconds 15 -ProbeCount 2
$RDPprobe = New-AzureRmLoadBalancerProbeConfig -Name 'RDPprobe' -Protocol Tcp -Port 3389 -IntervalInSeconds 15 -ProbeCount 2
#Create a load balancer rule
$lbrule1v4 = New-AzureRmLoadBalancerRuleConfig -Name "HTTPv4" -FrontendIpConfiguration $FEIPConfigv4 -BackendAddressPool $backendpoolipv4 -Probe $healthProbe -Protocol Tcp -FrontendPort 80 -BackendPort 80
$lbrule1v6 = New-AzureRmLoadBalancerRuleConfig -Name "HTTPv6" -FrontendIpConfiguration $FEIPConfigv6 -BackendAddressPool $backendpoolipv6 -Probe $healthProbe -Protocol Tcp -FrontendPort 80 -BackendPort 80
$RDPrule = New-AzureRmLoadBalancerRuleConfig -Name "RDPrule" -FrontendIpConfiguration $FEIPConfigv4 -BackendAddressPool $backendpoolipv4 -Probe $RDPprobe -Protocol Tcp -FrontendPort 3389 -BackendPort 3389
#Create the load balancer using the previously created objects
$NRPLB = New-AzureRmLoadBalancer -ResourceGroupName $rgname -Name 'snl-web-lb' -Location $locname -FrontendIpConfiguration $FEIPConfigv4,$FEIPConfigv6 -BackendAddressPool $backendpoolipv4,$backendpoolipv6 -Probe $healthProbe,$RDPprobe -LoadBalancingRule $lbrule1v4,$lbrule1v6,$RDPrule
#Create NICs for the back-end VMs
#Get the Virtual Network and Virtual Network Subnet, where the NICs need to be created.
$vnet = Get-AzureRmVirtualNetwork -Name VNet -ResourceGroupName $rgname
$backendSubnet = Get-AzureRmVirtualNetworkSubnetConfig -Name LB-Subnet-BE -VirtualNetwork $vnet
#Create IP configurations and NICs for the VMs.
$nic1IPv4 = New-AzureRmNetworkInterfaceIpConfig -Name "IPv4IPConfig" -PrivateIpAddressVersion "IPv4" -Subnet $backendSubnet -LoadBalancerBackendAddressPool $backendpoolipv4
$nic1IPv6 = New-AzureRmNetworkInterfaceIpConfig -Name "IPv6IPConfig" -PrivateIpAddressVersion "IPv6" -LoadBalancerBackendAddressPool $backendpoolipv6
$nic1 = New-AzureRmNetworkInterface -Name 'azr-web-srv' -IpConfiguration $nic1IPv4,$nic1IPv6 -ResourceGroupName $rgname -Location $locname
#Create an Availability Set and Storage account
New-AzureRmAvailabilitySet -Name 'WEB_AVSET' -ResourceGroupName $rgname -location $locname
$availabilitySet = Get-AzureRmAvailabilitySet -Name 'WEB_AVSET' -ResourceGroupName $rgname
#create a new storage account
New-AzureRmStorageAccount -ResourceGroupName $rgname -Name 'storage3648' -Location $locname -SkuName "Standard_LRS"

$CreatedStorageAccount = Get-AzureRmStorageAccount -ResourceGroupName $rgname -Name "storage3648"
#Create each VM and assign the previous created NICs

#Create a new windows VM
$mySecureCredentials= Get-Credential -Message "Type the username and password of the local administrator account."

$vm1 = New-AzureRmVMConfig -VMName 'myNrpIPv6VM0' -VMSize 'Standard_G1' -AvailabilitySetId $availabilitySet.Id
$vm1 = Set-AzureRmVMOperatingSystem -VM $vm1 -Windows -ComputerName 'myNrpIPv6VM0' -Credential $mySecureCredentials -ProvisionVMAgent -EnableAutoUpdate
$vm1 = Set-AzureRmVMSourceImage -VM $vm1 -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2012-R2-Datacenter -Version "latest"
$vm1 = Add-AzureRmVMNetworkInterface -VM $vm1 -Id $nic1.Id -Primary
$osDisk1Uri = $CreatedStorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/myNrpIPv6VM0osdisk.vhd"
$vm1 = Set-AzureRmVMOSDisk -VM $vm1 -Name 'myNrpIPv6VM0osdisk' -VhdUri $osDisk1Uri -CreateOption FromImage
New-AzureRmVM -ResourceGroupName NRP-RG -Location 'West US' -VM $vm1

# create a Linux VM from Uploaded VHD (generalised) from CLI
azure vm create AZR-WEB-SVR -l "Centralindia" --os-type linux --nic-name azr-web-srv --resource-group TestRg --vm-size "Standard_A1" --availset-name WEB_AVSET --storage-account-name storage3648 --os-disk-vhd AZR-UNFA01-SRV.vhd --image-urn https://storage3648.blob.core.windows.net/vhds/CentOSDisk.vhd
 