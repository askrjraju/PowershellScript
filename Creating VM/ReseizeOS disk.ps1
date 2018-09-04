$vm = Get-AzureRmVM -ResourceGroupName $rgName -Name $vmName
Stop-AzureRmVM -ResourceGroupName $rgName -Name $vmName
# for Windows OS disk
#$vm.StorageProfile.OSDisk.DiskSizeGB = 1023
#for Linux Disk
$vm.StorageProfile[0].OSDisk[0].DiskSizeGB = 1023 
Update-AzureRmVM -ResourceGroupName $rgName -VM $vm
Start-AzureRmVM -ResourceGroupName $rgName -Name $vmName
 
Login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionId '976102a7-8f1b-4006-9ef5-79404ad3ac7f'
$rgName = 'UNIFY_RSG'
$vmName = 'AZR-UNFDB01-SRV'
$vm = Get-AzureRmVM -ResourceGroupName $rgName -Name $vmName
Stop-AzureRmVM -ResourceGroupName $rgName -Name $vmName
# for Windows OS disk
$vm.StorageProfile.OSDisk.DiskSizeGB = 1023
Update-AzureRmVM -ResourceGroupName $rgName -VM $vm
Start-AzureRmVM -ResourceGroupName $rgName -Name $vmName
LAMP_RSG

#for Linux Disk
$vm.StorageProfile[0].OSDisk[0].DiskSizeGB = 1023 
