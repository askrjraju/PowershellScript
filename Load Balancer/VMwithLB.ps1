Import-Module AzureRM
$username = "rahul.singh@spectranet.in"
$password = ConvertTo-SecureString “M@chism0” -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password

#Sign in to Azure
Login-AzureRmAccount -Credential $cred
#Check the subscriptions for the account.
$AZR_Sub = Get-AzureRmSubscription
#Choose which of your Azure subscriptions to use.
Select-AzureRmSubscription -SubscriptionId $AZR_Sub.SubscriptionId

#Set the Workload Name
$WL = 'LAMP'
$location = 'southindia' #Set the Azure Region
$rgName = $WL +'_RSG' #Set the name of existing Resource Group

$StorageAccount = 'websitestg01' #Set the name of new storage account for vhds of VM
$vnet = Get-AzureRmvirtualNetwork #Get the Virtual Network
$backendSubnet = $WL + '_Subnet' #Set the name of backend subnet
$backendSubnet = $vnet.Subnets | Where-Object {$_.Name -eq $backendSubnet} #Get the backend subnet

$pubIPv4Name = $WL + '-PUB-IPV4'
$pubIPv6Name = $WL + '-PUB-IPV6'
$FEIPv4Name = $WL + 'LB-Frontendv4'
$FEIPv6Name = $WL + 'LB-Frontendv6'
$BEPoolV4Name = 'AZR-' + $WL + '-BEPOOL-IPv4'
$BEPoolV6Name = 'AZR-' + $WL + '-BEPOOL-IPv6'
$HTTPProbeName = 'AZR-HTTP-Probe-v4v6'
$HTTPSProbeName = 'AZR-HTTPS-Probe-v4v6'
$LBName = 'AZR-' + $WL + '-LB'
$vmName = 'AZR-LAMP01-SRV'
$nicName = $vmName + '-NIC'
$AVSetName = $WL + '_AVSET'
$ipv4Label = 'lb' + $WL + 'ipv4'
$ipv6Label = 'lb' + $WL + 'ipv6'
$Port_HTTP = 80
$Port_HTTPS = 443
$Port_SSH = 22

$AVSet = Get-AzureRmAvailabilitySet -ResourceGroupName $rgName -Name $AVSetName
$vm = Get-AzureRmVM -ResourceGroupName $rgName
$nic = Get-AzureRmNetworkInterface -ResourceGroupName $rgName
$publicIPv4 = Get-AzureRmPublicIpAddress -Name $pubIPv4Name -ResourceGroupName $rgName
$publicIPv6 = Get-AzureRmPublicIpAddress -Name $pubIPv6Name -ResourceGroupName $rgName
$NRPLB = Get-AzureRmLoadBalancer -Name $LBName -ResourceGroupName $rgName

if($vm) {
    if ($vm.Name -eq $vmName) {
        $osDiskVhdUri = $vm.StorageProfile.OsDisk.Vhd.Uri
        $osDiskName = $vm.StorageProfile.OsDisk.Name
        $vmSize = $vm.HardwareProfile.VmSize
        Stop-AzureRmVM -ResourceGroupName $rgName -Name $vmName
        Remove-AzureRmVM -ResourceGroupName $rgName -Name $vmName
    }
}

ForEach ($n in $nic) { if($n.VirtualMachine.Id -eq $vm.Id) { Remove-AzureRmNetworkInterface -ResourceGroupName $rgName -Name $n.Name } }

if ($NRPLB) { Remove-AzureRmLoadBalancer -Name $LBName -ResourceGroupName $rgName }

if ($publicIPv4) { Remove-AzureRmPublicIpAddress -Name $pubIPv4Name -ResourceGroupName $rgName }

if ($publicIPv6) { Remove-AzureRmPublicIpAddress -Name $pubIPv6Name -ResourceGroupName $rgName }

$publicIPv4 = New-AzureRmPublicIpAddress -Name $pubIPv4Name -ResourceGroupName $rgName -Location $location -AllocationMethod Dynamic -IpAddressVersion IPv4 -DomainNameLabel $ipv4Label.ToLower()    
$publicIPv6 = New-AzureRmPublicIpAddress -Name $pubIPv6Name -ResourceGroupName $rgName -Location $location -AllocationMethod Dynamic -IpAddressVersion IPv6 -DomainNameLabel $ipv6Label.ToLower()

$FEIPConfigv4 = New-AzureRmLoadBalancerFrontendIpConfig -Name $FEIPv4Name -PublicIpAddress $publicIPv4
$FEIPConfigv6 = New-AzureRmLoadBalancerFrontendIpConfig -Name $FEIPv6Name -PublicIpAddress $publicIPv6

$backendpoolipv4 = New-AzureRmLoadBalancerBackendAddressPoolConfig -Name $BEPoolV4Name
$backendpoolipv6 = New-AzureRmLoadBalancerBackendAddressPoolConfig -Name $BEPoolV6Name

$healthProbe80 = New-AzureRmLoadBalancerProbeConfig -Name $HTTPProbeName -Protocol Tcp -Port $Port_HTTP -IntervalInSeconds 15 -ProbeCount 2
$healthProbe443 = New-AzureRmLoadBalancerProbeConfig -Name $HTTPSProbeName -Protocol Tcp -Port $Port_HTTPS -IntervalInSeconds 15 -ProbeCount 2

$lbrule1v4 = New-AzureRmLoadBalancerRuleConfig -Name "HTTPv4" -FrontendIpConfiguration $FEIPConfigv4 -BackendAddressPool $backendpoolipv4 -Probe $healthProbe80 -Protocol Tcp -FrontendPort $Port_HTTP -BackendPort $Port_HTTP -LoadDistribution SourceIPProtocol
$lbrule1v6 = New-AzureRmLoadBalancerRuleConfig -Name "HTTPv6" -FrontendIpConfiguration $FEIPConfigv6 -BackendAddressPool $backendpoolipv6 -Probe $healthProbe80 -Protocol Tcp -FrontendPort $Port_HTTP -BackendPort $Port_HTTP -LoadDistribution SourceIPProtocol

$lbrule2v4 = New-AzureRmLoadBalancerRuleConfig -Name "HTTPSv4" -FrontendIpConfiguration $FEIPConfigv4 -BackendAddressPool $backendpoolipv4 -Probe $healthProbe443 -Protocol Tcp -FrontendPort $Port_HTTPS -BackendPort $Port_HTTPS -LoadDistribution SourceIPProtocol
$lbrule2v6 = New-AzureRmLoadBalancerRuleConfig -Name "HTTPSv6" -FrontendIpConfiguration $FEIPConfigv6 -BackendAddressPool $backendpoolipv6 -Probe $healthProbe443 -Protocol Tcp -FrontendPort $Port_HTTPS -BackendPort $Port_HTTPS -LoadDistribution SourceIPProtocol

$NRPLB = New-AzureRmLoadBalancer -ResourceGroupName $rgName -Name $LBName -Location $location -FrontendIpConfiguration $FEIPConfigv4,$FEIPConfigv6 -BackendAddressPool $backendpoolipv4,$backendpoolipv6 -Probe $healthProbe80,$healthProbe443 -LoadBalancingRule $lbrule1v4,$lbrule1v6,$lbrule2v4,$lbrule2v6



$nicIPv4 = New-AzureRmNetworkInterfaceIpConfig -Name "IPv4IPConfig" -PrivateIpAddressVersion "IPv4" -Subnet $backendSubnet -LoadBalancerBackendAddressPool $backendpoolipv4 
$nicIPv6 = New-AzureRmNetworkInterfaceIpConfig -Name "IPv6IPConfig" -PrivateIpAddressVersion "IPv6" -LoadBalancerBackendAddressPool $backendpoolipv6 
$nic = New-AzureRmNetworkInterface -Name $nicName -IpConfiguration $nicIPv4,$nicIPv6 -ResourceGroupName $rgName -Location $location

$vm = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize -AvailabilitySetId $AVSet.Id

$vm = Set-AzureRmVMOSDisk -VM $vm -VhdUri $osDiskVhdUri -Name $osDiskName -Caching ReadWrite -Linux -CreateOption Attach

$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id -Primary
New-AzureRmVM -ResourceGroupName $rgName -Location $location -VM $vm
