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
$WL = 'CRM'
$location = 'southindia' #Set the Azure Region
$rgName = $WL +'_RSG' #Set the name of existing Resource Group

$vnet = Get-AzureRmvirtualNetwork #Get the Virtual Network
$Subnet1 = $WL + 'APP_LAN_Subnet' #Set the name of backend subnet
$Subnet2 = $WL + 'APP_WAN_Subnet' #Set the name of backend subnet
$SubnetBackEnd1 = $vnet.Subnets | Where-Object {$_.Name -eq $Subnet1}
$SubnetBackEnd2 = $vnet.Subnets | Where-Object {$_.Name -eq $Subnet2}

$LB1Name = 'SNL-' + $WL + '-LB'
$LB2Name = 'AZR-' + $WL + '-LB'

$Ports = 80,8084,8810,8081,8085,8855,8070,8856,4488,8488,5555,8555,8090,8082,443,9084,9810,9081,9085,9855,9070,9856,9488,9555,9090,9082
$FE1IPv4Name = 'SNL-' + $WL + 'LB-Frontendv4'
$BEPool1Name = 'SNL-' + $WL + 'BEPOOL-IPv4'
$FE2IPv4Name = 'AZR-' + $WL + 'LB-Frontendv4'
$BEPool2Name = 'AZR-' + $WL + 'BEPOOL-IPv4'
$PrivIP = 10.158.103.21
$PubIPName = $WL + '-PUB-IPV4'
$ipv4Label = 'lb' + $WL + 'ipv4'

$AVSetName = $WL + 'APP_AVSET'
$vm1Name = 'AZR-CRMF01-SRV'
$vm2Name = 'AZR-CRMF02-SRV'
$vm1nic1Name = $vm1Name + '-PRIV-NIC'
$vm1nic2Name = $vm1Name + '-PUB-NIC'
$vm2nic1Name = $vm2Name + '-PRIV-NIC'
$vm2nic2Name = $vm2Name + '-PUB-NIC'

$AVSet = Get-AzureRmAvailabilitySet -ResourceGroupName $rgName -Name $AVSetName
$vm = Get-AzureRmVM -ResourceGroupName $rgName 
$nic = Get-AzureRmNetworkInterface -ResourceGroupName $rgName

Foreach ($v in $vm) {
    If ($v.Name -eq $vm1Name) {
        $vm1osDiskVhdUri = $v.StorageProfile.OsDisk.Vhd.Uri
        $vm1osDiskName = $v.StorageProfile.OsDisk.Name
        $vm1Size = $v.HardwareProfile.VmSize
        Stop-AzureRmVM -ResourceGroupName $rgName -Name $vm1Name -Confirm:$false
        Remove-AzureRmVM -ResourceGroupName $rgName -Name $vm1Name -Confirm:$false
        ForEach ($n in $nic) { if($n.VirtualMachine.Id -eq $v.Id) { Remove-AzureRmNetworkInterface -ResourceGroupName $rgName -Name $n.Name -Confirm:$false} }
    }
    ElseIf ($v.Name -eq $vm2Name) {
        $vm2osDiskVhdUri = $v.StorageProfile.OsDisk.Vhd.Uri
        $vm2osDiskName = $v.StorageProfile.OsDisk.Name
        $vm2Size = $v.HardwareProfile.VmSize
        Stop-AzureRmVM -ResourceGroupName $rgName -Name $vm2Name -Confirm:$false
        Remove-AzureRmVM -ResourceGroupName $rgName -Name $vm2Name -Confirm:$false
        ForEach ($n in $nic) { if($n.VirtualMachine.Id -eq $v.Id) { Remove-AzureRmNetworkInterface -ResourceGroupName $rgName -Name $n.Name -Confirm:$false} }
    }
}

$PubIP = Get-AzureRmPublicIpAddress -Name $PubIPName -ResourceGroupName $rgName
if ($PubIP -eq $null) {
$PubIP = New-AzureRmPublicIpAddress -Name $PubIPName -ResourceGroupName $rgName -Location $location -AllocationMethod Dynamic -IpAddressVersion IPv4 -DomainNameLabel $ipv4Label.ToLower()    
}

$NRPLB1 = Get-AzureRmLoadBalancer -Name $LB1Name -ResourceGroupName $rgName
if ($NRPLB1) {
    $FE1IPConfigv4 = $NRPLB1.FrontendIpConfigurations | Where {$_.Name -eq $FE1IPv4Name}
    $BEPool1 = $NRPLB1.BackendAddressPools | Where {$_.Name -eq $BEPool1Name}
} Else {
    $FE1IPConfigv4 = New-AzureRmLoadBalancerFrontendIpConfig -Name $FE1IPv4Name -SubnetId $SubnetBackEnd1.Id -PrivateIpAddress 10.158.103.21
    $BEPool1 = New-AzureRmLoadBalancerBackendAddressPoolConfig -Name $BEPool1Name
    $NRPLB1 = New-AzureRmLoadBalancer -ResourceGroupName $rgName -Name $LB1Name -Location $location -FrontendIpConfiguration $FE1IPConfigv4 -BackendAddressPool $BEPool1
}
$NRPLB2 = Get-AzureRmLoadBalancer -Name $LB2Name -ResourceGroupName $rgName
if ($NRPLB2) {
    $FE2IPConfigv4 = $NRPLB2.FrontendIpConfigurations | Where {$_.Name -eq $FE2IPv4Name}
    $BEPool2 = $NRPLB2.BackendAddressPools | Where {$_.Name -eq $BEPool2Name}
} Else {
    $FE2IPConfigv4 = New-AzureRmLoadBalancerFrontendIpConfig -Name $FE2IPv4Name -PublicIpAddress $PubIP
    $BEPool2 = New-AzureRmLoadBalancerBackendAddressPoolConfig -Name $BEPool2Name
    $NRPLB2 = New-AzureRmLoadBalancer -ResourceGroupName $rgName -Name $LB2Name -Location $location -FrontendIpConfiguration $FE2IPConfigv4 -BackendAddressPool $BEPool2
}



    
    ForEach ($Port in $Ports) {
        $probe1Name = "SNL-CRM-PROBE_" + $Port
        $probe2Name = "AZR-CRM-PROBE_" + $Port
        $NRPLB1 | Add-AzureRmLoadBalancerProbeConfig -Name $probe1Name -Protocol Tcp -Port $Port -IntervalInSeconds 15 -ProbeCount 2 | Set-AzureRmLoadBalancer
        $NRPLB2 | Add-AzureRmLoadBalancerProbeConfig -Name $probe2Name -Protocol Tcp -Port $Port -IntervalInSeconds 15 -ProbeCount 2 | Set-AzureRmLoadBalancer
    }

     ForEach ($Port in $Ports) {
        $probe1Name = "SNL-CRM-PROBE_" + $Port
        $probe2Name = "AZR-CRM-PROBE_" + $Port
        $LBRuleName = 'TCPv4_' + $port
        $Probe1 = Get-AzureRmLoadBalancerProbeConfig -LoadBalancer $NRPLB1 -Name $Probe1Name
        $Probe2 = Get-AzureRmLoadBalancerProbeConfig -LoadBalancer $NRPLB2 -Name $Probe2Name
        $NRPLB1 | Add-AzureRmLoadBalancerRuleConfig -Name $LBRuleName -FrontendIpConfigurationId $FE1IPConfigv4.Id -BackendAddressPoolId $BEPool1.Id -ProbeId $Probe1.Id -Protocol Tcp -FrontendPort $Probe1.Port -BackendPort $Probe1.Port | Set-AzureRmLoadBalancer
        $NRPLB2 | Add-AzureRmLoadBalancerRuleConfig -Name $LBRuleName -FrontendIpConfigurationId $FE2IPConfigv4.Id -BackendAddressPoolId $BEPool2.Id -ProbeId $Probe2.Id -Protocol Tcp -FrontendPort $Probe2.Port -BackendPort $Probe2.Port | Set-AzureRmLoadBalancer

    }

$vm1nic1IPv4 = New-AzureRmNetworkInterfaceIpConfig -Name "PrivIPv4IPConfig" -PrivateIpAddressVersion "IPv4" -Subnet $SubnetBackEnd1 -LoadBalancerBackendAddressPool $BEPool1
$vm1nic1 = New-AzureRmNetworkInterface -Name $vm1nic1Name -IpConfiguration $vm1nic1IPv4 -ResourceGroupName $rgName -Location $location

$vm1nic2IPv4 = New-AzureRmNetworkInterfaceIpConfig -Name "PubIPv4IPConfig" -PrivateIpAddressVersion "IPv4" -Subnet $SubnetBackEnd2 -LoadBalancerBackendAddressPool $BEPool2
$vm1nic2 = New-AzureRmNetworkInterface -Name $vm1nic2Name -IpConfiguration $vm1nic2IPv4 -ResourceGroupName $rgName -Location $location

$vm2nic1IPv4 = New-AzureRmNetworkInterfaceIpConfig -Name "PrivIPv4IPConfig" -PrivateIpAddressVersion "IPv4" -Subnet $SubnetBackEnd1 -LoadBalancerBackendAddressPool $BEPool1
$vm2nic1 = New-AzureRmNetworkInterface -Name $vm2nic1Name -IpConfiguration $vm1nic1IPv4 -ResourceGroupName $rgName -Location $location

$vm2nic2IPv4 = New-AzureRmNetworkInterfaceIpConfig -Name "PubIPv4IPConfig" -PrivateIpAddressVersion "IPv4" -Subnet $SubnetBackEnd2 -LoadBalancerBackendAddressPool $BEPool2
$vm2nic2 = New-AzureRmNetworkInterface -Name $vm2nic2Name -IpConfiguration $vm2nic2IPv4 -ResourceGroupName $rgName -Location $location

$vm1 = New-AzureRmVMConfig -VMName $vm1Name -VMSize $vm1Size -AvailabilitySetId $AVSet.Id
$vm2 = New-AzureRmVMConfig -VMName $vm2Name -VMSize $vm2Size -AvailabilitySetId $AVSet.Id

$vm1 = Set-AzureRmVMOSDisk -VM $vm1 -VhdUri $vm1osDiskVhdUri -Name $vm1osDiskName -Caching ReadWrite -Windows -CreateOption Attach
$vm2 = Set-AzureRmVMOSDisk -VM $vm2 -VhdUri $vm2osDiskVhdUri -Name $vm2osDiskName -Caching ReadWrite -Windows -CreateOption Attach

$vm1 = Add-AzureRmVMNetworkInterface -VM $vm1 -Id $vm1nic1.Id -Primary
$vm1 = Add-AzureRmVMNetworkInterface -VM $vm1 -Id $vm1nic2.Id
$vm2 = Add-AzureRmVMNetworkInterface -VM $vm2 -Id $vm2nic1.Id -Primary
$vm2 = Add-AzureRmVMNetworkInterface -VM $vm2 -Id $vm2nic2.Id

New-AzureRmVM -ResourceGroupName $rgName -Location $location -VM $vm1
New-AzureRmVM -ResourceGroupName $rgName -Location $location -VM $vm2

