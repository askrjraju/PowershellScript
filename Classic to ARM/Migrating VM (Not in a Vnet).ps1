Login-AzureRmAccount
Get-AzureRmSubscription
Select-AzureRmSubscription -SubscriptionId e778d4ff-7299-4e02-90ff-a7e23c326f20
Register-AzureRmResourceProvider -ProviderNamespace microsoft.classicinfrastructuremigrate
Get-AzureRmResourceProvider -ProviderNamespace Microsoft.ClassicInfrastructureMigrate
Add-AzureAccount
Get-AzureSubscription
Select-AzureSubscription -SubscriptionId e778d4ff-7299-4e02-90ff-a7e23c326f20
#Migrating a Vm not in a Vnet: (Creating new Virtual network in ARM)
# get the cloudservice
get-azureservice | ft servicename
# set the variables:
$servicename = "classicvmwovnet"
$deployment = Get-AzureDeployment -ServiceName $servicename
$deploymentname = $deployment.DeploymentName
Move-AzureService -Prepare -ServiceName $servicename -DeploymentName $deploymentname -CreateNewVirtualNetwork
Move-AzureService -Commit -ServiceName $servicename -DeploymentName $deploymentname 
