Login-AzureRmAccount
ge
Set-AzureRmContext -Subscription b20fc038-84dd-469b-a9c1-e035038f53ef
Get-AzureRmResourceProvider -ListAvailable | Select-Object ProviderNamespace, RegistrationState

Register-AzureRmResourceProvider -ProviderNamespace Microsoft.Batch