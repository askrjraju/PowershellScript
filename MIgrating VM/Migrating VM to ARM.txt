# Login-AzureRmAccount
# Get-AzureRmSubscription
# Select-AzureRmSubscription -SubscriptionId

# register classic the subscription : Register-AzureRmResourceProvider -ProviderNamespace Microsoft.ClassicInfrastructureMigrate
# To check the status of registering : Get-AzureRmResourceProvider -ProviderNamespace Microsoft.ClassicInfrastructureMigrate

# Login to classic subscription : Add-AzureAccount
# check the core limits available in ARM : Get-AzureRmVMUsage -Location

   Migrating IAAS resources
# Get the list of cloud services : Get-AzureService | ft ServiceName

# Get the deployment name for the cloud service : 
$servicename = "classicvmoyo"
$deployment = Get-AzureDeployment -ServiceName $servicename
$deploymentname = $deployment.DeploymentName

Migrate to with VNet

#Prepare the virtual network for migration
$VnetName = "classicvnet"
Move-AzureVirtualNetwork -Prepare -VirtualNetworkName $vnetName

#Commit the migration
Move-AzureVirtualNetwork -Commit -VirtualNetworkName $vnetName

# Migrate a storage account :
$storageacountname = "classicvmstoragetest"
Move-AzureStorageAccount -Prepare -StorageAccountName $storageacountname
Move-AzureStorageAccount -Commit  -StorageAccountName $storageacountname




