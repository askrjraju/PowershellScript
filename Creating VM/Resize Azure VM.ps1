Login-AzureRmAccount
Get-AzureRmSubscription
Select-AzureRmSubscription -SubscriptionId c1968c35-6f94-4c94-9b17-0b21aaa11975


$ResourceGroupName = "southrg"
$VMName = "dcserver"
$NewVMSize = "Standard_A2"
 
$vm = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VMName
$vm.HardwareProfile.vmSize = $NewVMSize
Update-AzureRmVM -ResourceGroupName $ResourceGroupName -VM $vm


