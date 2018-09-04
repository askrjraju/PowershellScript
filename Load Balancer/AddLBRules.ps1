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

#$StorageAccount = 'websitestg01' #Set the name of new storage account for vhds of VM
$vnet = Get-AzureRmvirtualNetwork #Get the Virtual Network
$backendSubnet = $WL + '_Subnet' #Set the name of backend subnet
$backendSubnet = $vnet.Subnets | Where-Object {$_.Name -eq $backendSubnet} #Get the backend subnet

$pubIPv4Name = $WL + '-PUB-IPV4'
$pubIPv6Name = $WL + '-PUB-IPV6'
$FEIPv4Name = $WL + 'LB-Frontendv4'
$FEIPv6Name = $WL + 'LB-Frontendv6'
$BEPoolV4Name = 'AZR-' + $WL + '-BEPOOL-IPv4'
$BEPoolV6Name = 'AZR-' + $WL + '-BEPOOL-IPv6'

$LBName = 'AZR-' + $WL + '-LB'
$vmName = 'AZR-LAMP01-SRV'
$nicName = $vmName + '-NIC'
$AVSetName = $WL + '_AVSET'
$ipv4Label = 'lb' + $WL + 'ipv4'
$ipv6Label = 'lb' + $WL + 'ipv6'

$AVSet = Get-AzureRmAvailabilitySet -ResourceGroupName $rgName -Name $AVSetName

$nic = Get-AzureRmNetworkInterface -ResourceGroupName $rgName
$publicIPv4 = Get-AzureRmPublicIpAddress -Name $pubIPv4Name -ResourceGroupName $rgName
$publicIPv6 = Get-AzureRmPublicIpAddress -Name $pubIPv6Name -ResourceGroupName $rgName

$NRPLB = Get-AzureRmLoadBalancer -Name $LBName -ResourceGroupName $rgName


    $NRPLB | Add-AzureRmLoadBalancerProbeConfig -Name "AZR-13000-Probe-v4v6" -Protocol Tcp -Port 13000 -IntervalInSeconds 15 -ProbeCount 2
    $NRPLB | Add-AzureRmLoadBalancerProbeConfig -Name "AZR-13001-Probe-v4v6" -Protocol Tcp -Port 13001 -IntervalInSeconds 15 -ProbeCount 2
    $NRPLB | Add-AzureRmLoadBalancerProbeConfig -Name "AZR-13013-Probe-v4v6" -Protocol Tcp -Port 13013 -IntervalInSeconds 15 -ProbeCount 2

    $Probe = Get-AzureRmLoadBalancerProbeConfig -LoadBalancer $NRPLB -Name "AZR-HTTPS-Probe-v4v6"
    
    $FEIPConfigv4 = $NRPLB.FrontendIpConfigurations | Where {$_.Name -eq "LAMPLB-Frontendv4"}
    $BEIPPoolv4 = $NRPLB.BackendAddressPools | Where {$_.Name -eq "AZR-LAMP-BEPOOL-IPv4"}
    $FEIPConfigv6 = $NRPLB.FrontendIpConfigurations | Where {$_.Name -eq "LAMPLB-Frontendv6"}
    $BEIPPoolv6 = $NRPLB.BackendAddressPools | Where {$_.Name -eq "AZR-LAMP-BEPOOL-IPv6"}

    $Probe = Get-AzureRmLoadBalancerProbeConfig -LoadBalancer $NRPLB -Name "AZR-13000-Probe-v4v6"
    $NRPLB | Add-AzureRmLoadBalancerRuleConfig -Name "TCPv4_13000" -FrontendIpConfigurationId $FEIPConfigv4.Id -BackendAddressPoolId $BEIPPoolv4.Id -ProbeId $Probe.Id -Protocol Tcp -FrontendPort $Probe.Port -BackendPort $Probe.Port
    $NRPLB | Add-AzureRmLoadBalancerRuleConfig -Name "TCPv6_13000" -FrontendIpConfigurationId $FEIPConfigv6.Id -BackendAddressPoolId $BEIPPoolv6.Id -ProbeId $Probe.Id -Protocol Tcp -FrontendPort $Probe.Port -BackendPort $Probe.Port

    $Probe = Get-AzureRmLoadBalancerProbeConfig -LoadBalancer $NRPLB -Name "AZR-13001-Probe-v4v6"
    $NRPLB | Add-AzureRmLoadBalancerRuleConfig -Name "TCPv4_13001" -FrontendIpConfigurationId $FEIPConfigv4.Id -BackendAddressPoolId $BEIPPoolv4.Id -ProbeId $Probe.Id -Protocol Tcp -FrontendPort $Probe.Port -BackendPort $Probe.Port
    $NRPLB | Add-AzureRmLoadBalancerRuleConfig -Name "TCPv6_13001" -FrontendIpConfigurationId $FEIPConfigv6.Id -BackendAddressPoolId $BEIPPoolv6.Id -ProbeId $Probe.Id -Protocol Tcp -FrontendPort $Probe.Port -BackendPort $Probe.Port

    $Probe = Get-AzureRmLoadBalancerProbeConfig -LoadBalancer $NRPLB -Name "AZR-13013-Probe-v4v6"
    $NRPLB | Add-AzureRmLoadBalancerRuleConfig -Name "TCPv4_13013" -FrontendIpConfigurationId $FEIPConfigv4.Id -BackendAddressPoolId $BEIPPoolv4.Id -ProbeId $Probe.Id -Protocol Tcp -FrontendPort $Probe.Port -BackendPort $Probe.Port
    $NRPLB | Add-AzureRmLoadBalancerRuleConfig -Name "TCPv6_13013" -FrontendIpConfigurationId $FEIPConfigv6.Id -BackendAddressPoolId $BEIPPoolv6.Id -ProbeId $Probe.Id -Protocol Tcp -FrontendPort $Probe.Port -BackendPort $Probe.Port

    Set-AzureRmLoadBalancer -LoadBalancer $NRPLB -Verbose 

    
    