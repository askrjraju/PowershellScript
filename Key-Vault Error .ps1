$RGName = "jtl-Migrated"
$vmName = "test"

$vm = Get-AzureRmVM -ResourceGroupName $RGName -Name $vmName

$vm.OSProfile.Secrets = New-Object -TypeName "System.Collections.Generic.List[Microsoft.Azure.Management.Compute.Models.VaultSecretGroup]"

Update-AzureRmVM -ResourceGroupName $RGName -VM $vm