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
$AVSetName = $WL + 'APP_AVSET'
$vm1Name = 'AZR-CRMF01-SRV'
$vm2Name = 'AZR-CRMF02-SRV'
$vm1nic1Name = $vm1Name + '-PRIV-NIC'
$vm1nic2Name = $vm1Name + '-PUB-NIC'
$vm2nic1Name = $vm2Name + '-PRIV-NIC'
$vm2nic2Name = $vm2Name + '-PUB-NIC'


#$StorageAccount = 'crmstg01' #Set the name of new storage account for vhds of VM
$vnet = Get-AzureRmvirtualNetwork #Get the Virtual Network
$Subnet1 = $WL + 'APP_LAN_Subnet' #Set the name of backend subnet
$Subnet2 = $WL + 'APP_WAN_Subnet' #Set the name of backend subnet

$AVSet = Get-AzureRmAvailabilitySet -ResourceGroupName $rgName -Name $AVSetName
$vm = Get-AzureRmVM -ResourceGroupName $rgName 
$nic = Get-AzureRmNetworkInterface -ResourceGroupName $rgName

Foreach ($v in $vm) {
    If ($v.Name -eq $vm1Name) {
        $vm1osDiskVhdUri = $v.StorageProfile.OsDisk.Vhd.Uri
        $vm1osDiskName = $v.StorageProfile.OsDisk.Name
        $vm1Size = $v.HardwareProfile.VmSize
        Stop-AzureRmVM -ResourceGroupName $rgName -Name $vm1Name
        Remove-AzureRmVM -ResourceGroupName $rgName -Name $vm1Name
        ForEach ($n in $nic) { if($n.VirtualMachine.Id -eq $v.Id) { Remove-AzureRmNetworkInterface -ResourceGroupName $rgName -Name $n.Name } }
    }
    ElseIf ($v.Name -eq $vm2Name) {
        $vm2osDiskVhdUri = $v.StorageProfile.OsDisk.Vhd.Uri
        $vm2osDiskName = $v.StorageProfile.OsDisk.Name
        $vm2Size = $v.HardwareProfile.VmSize
        Stop-AzureRmVM -ResourceGroupName $rgName -Name $vm2Name
        Remove-AzureRmVM -ResourceGroupName $rgName -Name $vm2Name
        ForEach ($n in $nic) { if($n.VirtualMachine.Id -eq $v.Id) { Remove-AzureRmNetworkInterface -ResourceGroupName $rgName -Name $n.Name } }
    }
}

#$SubnetFrontEnd1 = New-AzureRmVirtualNetworkSubnetConfig -Name $Subnet1 -AddressPrefix "10.159.103.0/27" 
#$SubnetFrontEnd2 = New-AzureRmVirtualNetworkSubnetConfig -Name $Subnet2 -AddressPrefix "10.159.103.32/27"

$SubnetFrontEnd1 = $vnet.Subnets | Where-Object {$_.Name -eq $Subnet1}
$SubnetFrontEnd2 = $vnet.Subnets | Where-Object {$_.Name -eq $Subnet2}

$LB1Name = 'SNL-' + $WL + '-LB'
$LB2Name = 'AZR-' + $WL + '-LB'
$FE1IPv4Name = 'SNL-' + $WL + 'LB-Frontendv4'
$BEPool1Name = 'SNL-' + $WL + 'BEPOOL-IPv4'
$FE2IPv4Name = 'AZR-' + $WL + 'LB-Frontendv4'
$BEPool2Name = 'AZR-' + $WL + 'BEPOOL-IPv4'

$NRPLB1 = Get-AzureRmLoadBalancer -Name $LB1Name -ResourceGroupName $rgName
$NRPLB2 = Get-AzureRmLoadBalancer -Name $LB2Name -ResourceGroupName $rgName
$BEPool1 = $NRPLB1.BackendAddressPools | Where {$_.Name -eq $BEPool1Name}
$BEPool2 = $NRPLB2.BackendAddressPools | Where {$_.Name -eq $BEPool2Name}


$vm1nic1IPv4 = New-AzureRmNetworkInterfaceIpConfig -Name "PrivIPv4IPConfig" -PrivateIpAddressVersion "IPv4" -Subnet $SubnetFrontEnd1 -LoadBalancerBackendAddressPool $BEPool1
$vm1nic1 = New-AzureRmNetworkInterface -Name $vm1nic1Name -IpConfiguration $vm1nic1IPv4 -ResourceGroupName $rgName -Location $location

$vm1nic2IPv4 = New-AzureRmNetworkInterfaceIpConfig -Name "PubIPv4IPConfig" -PrivateIpAddressVersion "IPv4" -Subnet $SubnetFrontEnd2 -LoadBalancerBackendAddressPool $BEPool2
$vm1nic2 = New-AzureRmNetworkInterface -Name $vm1nic2Name -IpConfiguration $vm1nic2IPv4 -ResourceGroupName $rgName -Location $location

$vm2nic1IPv4 = New-AzureRmNetworkInterfaceIpConfig -Name "PrivIPv4IPConfig" -PrivateIpAddressVersion "IPv4" -Subnet $SubnetFrontEnd1 -LoadBalancerBackendAddressPool $BEPool1
$vm2nic1 = New-AzureRmNetworkInterface -Name $vm2nic1Name -IpConfiguration $vm1nic1IPv4 -ResourceGroupName $rgName -Location $location

$vm2nic2IPv4 = New-AzureRmNetworkInterfaceIpConfig -Name "PubIPv4IPConfig" -PrivateIpAddressVersion "IPv4" -Subnet $SubnetFrontEnd2 -LoadBalancerBackendAddressPool $BEPool2
$vm2nic2 = New-AzureRmNetworkInterface -Name $vm2nic2Name -IpConfiguration $vm2nic2IPv4 -ResourceGroupName $rgName -Location $location

#$vm1osDiskVhdUri = "https://crmstg01.blob.core.windows.net/vhds/AZR-CRMF01-SRV20170206223555.vhd"
#$vm2osDiskVhdUri = "https://crmstg02.blob.core.windows.net/vhds/AZR-CRMF02-SRV20170206224834.vhd"
#$vm1osDiskName = "AZR-CRMF01-SRV"
#$vm2osDiskName = "AZR-CRMF02-SRV"
#$vm1Size = "Standard_D2_v2"
#$vm2Size = "Standard_D2_v2"

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