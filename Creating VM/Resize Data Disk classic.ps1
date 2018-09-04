Import-Module azure
Set-ExecutionPolicy Unrestricted
Add-AzureAccount
Get-AzureSubscription
Select-AzureSubscription -SubscriptionId  99950727-215e-472c-9a97-303a2163d7b8
https://vlccerpaxdbsrvstorage.blob.core.windows.net/vhds/DataDisk1-Axbd-srvr-0315-1.vhd

VLCCADCAzure-Axbd-srvr-0-201603150711290285
vlccerpax-cs.cloudapp.net

Get-AzureVM -ServiceName "vlccerpax-cs" -Name “Axbd-srvr” | Get-AzureDataDisk
Get-AzureService | FT

Update-AzureDisk -DiskName VLCCADCAzure-Axbd-srvr-0-201603150711290285 -Label ResizeDataDisk -ResizedSizeInGB 750