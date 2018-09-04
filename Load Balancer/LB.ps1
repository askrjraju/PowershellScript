$username = "rahul.singh@spectranet.in"
$password = ConvertTo-SecureString “M@chism0” -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password
Login-AzureRmAccount -Credential $cred
$AZR_Sub = Get-AzureRmSubscription
Select-AzureRmSubscription -SubscriptionId $AZR_Sub.SubscriptionId

$location = 'southindia'
$vnet = Get-AzureRmvirtualNetwork
$rgName = 'WEB_RSG'
$vmName = 'AZR-WBSITE-SRV'

$publicIPv4 = New-AzureRmPublicIpAddress -Name 'WEB-PUB-IPV4' -ResourceGroupName $rgName -Location $location -AllocationMethod Dynamic -IpAddressVersion IPv4 -DomainNameLabel lbwebipv4
$publicIPv6 = New-AzureRmPublicIpAddress -Name 'WEB-PUB-IPV6' -ResourceGroupName $rgName -Location $location -AllocationMethod Dynamic -IpAddressVersion IPv6 -DomainNameLabel lbwebipv6

$FEIPConfigv4 = New-AzureRmLoadBalancerFrontendIpConfig -Name "WEBLB-Frontendv4" -PublicIpAddress $publicIPv4
$FEIPConfigv6 = New-AzureRmLoadBalancerFrontendIpConfig -Name "WEBLB-Frontendv6" -PublicIpAddress $publicIPv6

$backendpoolipv4 = New-AzureRmLoadBalancerBackendAddressPoolConfig -Name "SNL-WEB-BEPOOL-IPv4"
$backendpoolipv6 = New-AzureRmLoadBalancerBackendAddressPoolConfig -Name "SNL-WEB-BEPOOL-IPv6"

$healthProbe = New-AzureRmLoadBalancerProbeConfig -Name 'SNL-WEB-Probe-v4v6' -Protocol Tcp -Port 443 -IntervalInSeconds 15 -ProbeCount 2

$lbrule1v4 = New-AzureRmLoadBalancerRuleConfig -Name "HTTPSv4" -FrontendIpConfiguration $FEIPConfigv4 -BackendAddressPool $backendpoolipv4 -Probe $healthProbe -Protocol Tcp -FrontendPort 443 -BackendPort 443
$lbrule1v6 = New-AzureRmLoadBalancerRuleConfig -Name "HTTPSv6" -FrontendIpConfiguration $FEIPConfigv6 -BackendAddressPool $backendpoolipv6 -Probe $healthProbe -Protocol Tcp -FrontendPort 443 -BackendPort 443

$NRPLB = New-AzureRmLoadBalancer -ResourceGroupName NRP-RG -Name 'SNL-WEB-LB' -Location $location -FrontendIpConfiguration $FEIPConfigv4,$FEIPConfigv6 -BackendAddressPool $backendpoolipv4,$backendpoolipv6 -Probe $healthProbe -LoadBalancingRule $lbrule1v4,$lbrule1v6


 




