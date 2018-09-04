Login-AzureRmAccount
Get-AzureRmSubscription
Select-AzureRmSubscription -SubscriptionId e778d4ff-7299-4e02-90ff-a7e23c326f20
Register-AzureRmResourceProvider -ProviderNamespace microsoft.classicinfrastructuremigrate
Get-AzureRmResourceProvider -ProviderNamespace Microsoft.ClassicInfrastructureMigrate
Add-AzureAccount
Get-AzureSubscription
Select-AzureSubscription -SubscriptionId e778d4ff-7299-4e02-90ff-a7e23c326f20
# Migrating a vm (not in a vnet) in existing vnet
get-azureservice | ft servicename
# set the variables:
Get-AzureService | ft ServiceName
$servicename = "myvmclassic"
$deployment = Get-AzureDeployment -ServiceName $servicename
$deploymentname = $deployment.DeploymentName
$existingvnetrgame = "mytest"
$vnetname = "testvnet"
$subnetname = "default"
 Move-AzureService -Prepare -ServiceName $servicename -DeploymentName $deploymentname -UseExistingVirtualNetwork -VirtualNetworkResourceGroupName $existingvnetrgame -VirtualNetworkName $vnetname -SubnetName $subnetname
 Move-AzureService -Commit -ServiceName $servicename -DeploymentName $deploymentname
