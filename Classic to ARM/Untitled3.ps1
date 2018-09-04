Login-AzureRmAccount
Get-AzureRmSubscription
Select-AzureRmSubscription -SubscriptionId e778d4ff-7299-4e02-90ff-a7e23c326f20
Register-AzureRmResourceProvider -ProviderNamespace microsoft.classicinfrastructuremigrate
#To Chect the registeration 
Get-AzureRmResourceProvider -ProviderNamespace Microsoft.ClassicInfrastructureMigrate
Add-AzureAccount
Get-AzureSubscription
Select-AzureSubscription -SubscriptionId e778d4ff-7299-4e02-90ff-a7e23c326f20
# Migrating a VM (in a Vnet)
$vnetname = "classicvnet"
# validate if you can migrate the virtual network by using the following command:
Move-AzureVirtualNetwork -Validate -VirtualNetworkName $vnetName
Move-AzureVirtualNetwork -Prepare -VirtualNetworkName $vnetName
# To abort the Migration 
Move-AzureVirtualNetwork -Abort -VirtualNetworkName $vnetName
# Finally run the commit command
Move-AzureVirtualNetwork -Commit -VirtualNetworkName $vnetname
$storagename = "classicvmstrg"
Move-AzureStorageAccount -Prepare -StorageAccountName $storagename
Move-AzureStorageAccount -Commit -StorageAccountName $storagename
$storagename = "w4portalvhdswpxg5hr0n1vm"
Move-AzureStorageAccount -Prepare -StorageAccountName $storagename
Move-AzureStorageAccount -Commit -StorageAccountName $storagename




