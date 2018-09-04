$username = "lalit.vashisht@embee.co.in"
$Password = ConvertTo-SecureString "Pass@123" -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username , $Password
Login-AzureRmAccount -Credential $cred
$Azure_Subs = Get-AzureRmSubscription
Select-AzureRmSubscription -SubscriptionId $Azure_Subs.SubscriptionId
$rgname = "DLVRG"
$Location = "SouthIndia"
New-AzureRmResourceGroup -Name $rgname -Location $Location

#Create Vnet & Subnet
$BackendSubnet = New-AzureRmVirtualNetworkSubnetConfig -Name "Backend" -AddressPrefix 192.168.0.0/24
$vnet = New-AzureRmVirtualNetwork -Name "Vnet" -ResourceGroupName $rgname -Location $Location -AddressPrefix 192.168.0.0/16 -Subnet $BackendSubnet

#create Public IP
$PUIPV4 = New-AzureRmPublicIpAddress -Name "PUBIPV4" -ResourceGroupName $rgname -Location $Location -AllocationMethod Dynamic -IpAddressVersion IPv4 -DomainNameLabel "pubipv4"
$PUNIPV4 = New-AzureRmPublicIpAddress -Name "PUBIPV6" -ResourceGroupName $rgname -Location $Location -AllocationMethod Dynamic -IpAddressVersion IPv6 -DomainNameLabel "pubipv6"

# Create FronendPIconfig $ Backendpool Address for Load balancer
$FEIPconfigV4 = New-AzureRmLoadBalancerFrontendIpConfig -Name "LB-FEIPconfigV4" -PublicIpAddress $PUIPV4
$FEIPconfigV6 = New-AzureRmLoadBalancerFrontendIpConfig -Name "LB-FEIPconfigV6" -PublicIpAddress $PUNIPV4

$BackendPoolIPv4 = New-AzureRmLoadBalancerBackendAddressPoolConfig -Name "BackendPoolIPV4"
$BackendPoolIPv6 = New-AzureRmLoadBalancerBackendAddressPoolConfig -Name "BackendPoolIPV6"

# Create LB rules, a probe, and a load balancer
$healthProbe = New-AzureRmLoadBalancerProbeConfig -Name "PbobeIPV4V6" -Protocol Tcp -Port 80 -IntervalInSeconds 15 -ProbeCount 2
$healthProbe443 = New-AzureRmLoadBalancerProbeConfig -Name "ProbeV4V6" -Protocol Tcp -Port 443 -IntervalInSeconds 15 -ProbeCount 2

#LB rule
$LBRULEV4 = New-AzureRmLoadBalancerRuleConfig -Name "HTTPV4" -FrontendIpConfiguration $FEIPconfigV4 -BackendAddressPool $BackendPoolIPv4 -Probe $healthProbe -Protocol Tcp -FrontendPort 80 -BackendPort 80
$LBRULEV6 = New-AzureRmLoadBalancerRuleConfig -Name "HTTPV6" -FrontendIpConfiguration $FEIPconfigV6 -BackendAddressPool $BackendPoolIPv6 -Probe $healthProbe -Protocol Tcp -FrontendPort 80 -BackendPort 80  

$LB = New-AzureRmLoadBalancer -Name "AZR-LB" -ResourceGroupName $rgname -Location $Location -FrontendIpConfiguration $FEIPconfigV4,$FEIPconfigV6 -BackendAddressPool $BackendPoolIPv4,$BackendPoolIPv6 -Probe $healthProbe,$healthProbe443 -LoadBalancingRule $LBRULEV4,$LBRULEV6

# Create NICs for the back-end VMs
Get the Virtual Network and Virtual Network Subnet, where the NICs need to be created
$Vnet = Get-AzureRmVirtualNetwork -Name "Vnet" -ResourceGroupName $rgname
$subnetname = "Backend"
$subnet = $vnet.Subnets | Where-Object { $_.name -eq $subnetname }

Or 
$subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name $subnetname -VirtualNetwork $vnet

# Create NIC 
$NICIPV4 = New-AzureRmNetworkInterfaceIpConfig -Name "NICIPV4" -PrivateIpAddressVersion IPv4 -Subnet $subnet -LoadBalancerBackendAddressPool $BackendPoolIPv4 
$NICIPV6 = New-AzureRmNetworkInterfaceIpConfig -Name "NICIPV6" -PrivateIpAddressVersion IPv6 -LoadBalancerBackendAddressPool $BackendPoolIPv6
$nic = New-AzureRmNetworkInterface -Name "MyIPv4v6" -ResourceGroupName $rgname -Location $Location -IpConfiguration $NICIPV4,$NICIPV6

# create AVset
Create an Availability Set and Storage account
$Avset = New-AzureRmAvailabilitySet -Name "ADDS_AVSET" -ResourceGroupName $rgname -Location $Location
$Avset = Get-AzureRmAvailabilitySet -ResourceGroupName $rgname -Name "ADDS_AVSET"

New-AzureRmStorageAccount -Name "dlvvmstg01" -ResourceGroupName $rgname -SkuName Standard_LRS -Location $Location -Kind Storage -Verbose

# create VM
$cred = Get-Credential -Message "lalit 123@mail.com"
$vm = New-AzureRmVMConfig -VMName "DLVVM1" -VMSize "Standard_A1" -AvailabilitySetId $Avset.Id
$vm = Set-AzureRmVMOperatingSystem -VM $vm -Windows -ComputerName "DCSERVER" -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$vm = Set-AzureRmVMSourceImage -VM $vm -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2012-R2-Datacenter -Version "latest"
$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id
$staccount = Get-AzureRmStorageAccount -Name "dlvvmstg01" -ResourceGroupName $rgname 
$OsDiskUri = $staccount.PrimaryEndpoints.Blob.ToString() + "vhds/dlvmOsdisk.vhd"
$vm = Set-AzureRmVMOSDisk -VM $vm -Name "dlvmOsdisk" -VhdUri $OsDiskUri -Caching ReadWrite -CreateOption FromImage
New-AzureRmVM -ResourceGroupName $rgname -VM $vm -Location $Location 