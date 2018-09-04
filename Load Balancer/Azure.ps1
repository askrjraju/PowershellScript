Login-AzureRmAccount
$AZR_Sub = Get-AzureRmSubscription
Select-AzureRmSubscription -SubscriptionId $AZR_Sub.SubscriptionId
$rgName = 'LAMP_RSG'
$vmName = 'AZR-LAMP01-SRV'
$vm = Get-AzureRmVM -ResourceGroupName $rgName -Name $vmName
Stop-AzureRmVM -ResourceGroupName $rgName -Name $vmName
# for Windows OS disk
#$vm.StorageProfile.OSDisk.DiskSizeGB = 1023
#for Linux Disk
$vm.StorageProfile[0].OSDisk[0].DiskSizeGB = 1023 
Update-AzureRmVM -ResourceGroupName $rgName -VM $vm
Start-AzureRmVM -ResourceGroupName $rgName -Name $vmName
 
