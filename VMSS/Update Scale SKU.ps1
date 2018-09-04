$vmss = Get-AzureRmVmss -ResourceGroupName "CRMRG" -VMScaleSetName "VMSSCRMRG"  
$vmss.Sku.Capacity = 1
Update-AzureRmVmss -ResourceGroupName "CRMRG" -Name "VMSSCRMRG" -VirtualMachineScaleSet $vmss