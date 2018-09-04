Login-AzureRmAccount
Get-AzureRmSubscription
Select-AzureRmSubscription -SubscriptionId c1968c35-6f94-4c94-9b17-0b21aaa11975

# Create Resource Group
$RgName = "CRMRG"
$location = "southindia"

New-AzureRmResourceGroup -Name $RgName -Location $location

# create storage
$stname = "crmstg03"
$staccount = New-AzureRmStorageAccount -Name $stname -ResourceGroupName $RgName -SkuName Standard_LRS -Location $location -Kind Storage

# create Subnet/Vnet
$subnetname = "websubnet"
$Subnet1 = New-AzureRmVirtualNetworkSubnetConfig -Name $subnetname -AddressPrefix 192.168.1.0/24 
$vnetName = "CRMVET"
$vnet = New-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $RgName -Location $location -AddressPrefix 192.168.0.0/16 -Subnet $Subnet1
$vnet = Get-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $RgName
$SUbnetID = $vnet.Subnets[0].Id

#Public IP
$IPname = "CRMPUB"
$PIP = New-AzureRmPublicIpAddress -Name $IPname -ResourceGroupName $RgName -Location $location -AllocationMethod Dynamic -IpAddressVersion IPv4 -DomainNameLabel "crmpb"

$PIP = Get-AzureRmPublicIpAddress -Name $IPname -ResourceGroupName $RgName 

# Create LoadBalancer
$FrontendConfigname = "FE"+ $RgName
$BackendaddresspoolName = "BEPool" + $RgName
$LBrulename = "lbrule"+ $RgName
$ProbeName = "Probe" + $RgName
$LBName = "vmsslb" + $RGName
$InboundNatpoolName = "Innat" + $RgName
$frontendPortstartrange = 3360
$frontendPortendrange = 3370
$BackendVMport = 3389



# create FrontendIPconfig
$FrontendIPconfig = New-AzureRmLoadBalancerFrontendIpConfig -Name $FrontendConfigname -PublicIpAddress $PIP

# ceate the Backendaddresspool
$BackendaddressPool = New-AzureRmLoadBalancerBackendAddressPoolConfig -Name $BackendaddresspoolName 
$Probe = New-AzureRmLoadBalancerProbeConfig -Name $ProbeName -Protocol Tcp -Port 443 -IntervalInSeconds 15 -ProbeCount 2

# create Nat
$InnatPool = New-AzureRmLoadBalancerInboundNatPoolConfig -Name $InboundNatpoolName -FrontendIpConfigurationId $FrontendIPconfig.Id -Protocol Tcp -FrontendPortRangeStart 3360 -FrontendPortRangeEnd 3370 -BackendPort 3389

$lbrule = New-AzureRmLoadBalancerRuleConfig -Name $LBrulename -FrontendIpConfigurationId $FrontendIPconfig.Id -BackendAddressPoolId $BackendaddressPool.Id -ProbeId $Probe.Id -Protocol Tcp -FrontendPort 443 -BackendPort 443 -IdleTimeoutInMinutes 15 -EnableFloatingIP -LoadDistribution SourceIPProtocol -Verbose
$NRLB = New-AzureRmLoadBalancer -Name $LBName -ResourceGroupName $RgName -Location $location -FrontendIpConfiguration $FrontendIPconfig -BackendAddressPool $BackendaddressPool -Probe $Probe -LoadBalancingRule $lbrule -InboundNatPool $InnatPool
$NRLB = Get-AzureRmLoadBalancer -Name $LBName -ResourceGroupName $RgName


# New VMSS Parameters
$VMSSName = "VMSS" + $RGName;

$Username = "lalit"
$passwd =  "123@mail.com"

$PublisherName = "MicrosoftWindowsServer" 
$Offer         = "WindowsServer" 
$Sku           = "2012-R2-Datacenter" 
$Version       = "latest"

$ExtName = "CSETest";
$Publisher = "Microsoft.Compute";
$ExtType = "BGInfo";
$ExtVer = "2.1";

#IP Config for the NIC
$ipconfic = New-AzureRmVmssIpConfig -Name "vmssnic" -LoadBalancerBackendAddressPoolsId $NRLB.BackendAddressPools[0].Id -SubnetId $SUbnetID -LoadBalancerInboundNatPoolsId $NRLB.InboundNatPools[0].Id

$VHDContainer = "https://crmstg03.blob.core.windows.net/vhds"

#VMSS Config
$vmss = New-AzureRmVmssConfig -Location $location -SkuName "Standard_A2" -SkuCapacity 2 -UpgradePolicyMode Automatic | Add-AzureRmVmssNetworkInterfaceConfiguration -Name "Test" -Primary $true -IpConfiguration $ipconfic  | Set-AzureRmVmssOsProfile -ComputerNamePrefix "CRMVMSSVM" -AdminUsername $Username -AdminPassword $passwd | Set-AzureRmVmssStorageProfile -ImageReferencePublisher $PublisherName -ImageReferenceOffer $Offer -ImageReferenceSku $Sku -ImageReferenceVersion $Version -Name "crmprofile" -OsDiskCreateOption FromImage -OsDiskCaching None -VhdContainer $VHDContainer | Add-AzureRmVmssExtension -Name $ExtName -Publisher $Publisher -Type $ExtType -TypeHandlerVersion $ExtVer -AutoUpgradeMinorVersion $true
New-AzureRmVmss -ResourceGroupName $RgName -Name $VMSSNAME -VirtualMachineScaleSet $vmss