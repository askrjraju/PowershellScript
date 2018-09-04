$vm = Get-AzureRmVM -ResourceGroupName $rg -Name $name
$vm.OSProfile.windowsConfiguration.provisionVMAgent = $True
Update-AzureRmVM -ResourceGroupName $rg -VM $vm 
