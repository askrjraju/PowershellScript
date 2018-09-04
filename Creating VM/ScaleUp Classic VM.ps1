Add-AzureAccount
Get-AzureSubscription
Get-Help -Name Get-AzureVM -Detailed , (Example)
get-azureservice | ft servicename
Get-AzureVM -ServiceName "Webvmcld" -Name "Webvm" | Set-AzureVMSize "A6" | Update-AzureVM
 