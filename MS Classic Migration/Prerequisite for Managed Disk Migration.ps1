# Destination Subs
Set-AzureRmContext -Subscription 1ef3d826-ff60-4269-92c1-050346838a98
Get-AzureRmResourceProvider -ListAvailable | Select-Object ProviderNamespace, RegistrationState

# Source Subs
(Get-AzureRmSubscription -SubscriptionID 1ef3d826-ff60-4269-92c1-050346838a98 ).TenantId
# Destination Subs
(Get-AzureRmSubscription -SubscriptionID 4d56d475-ad95-4ddc-a061-1a1111884730 ).TenantId

# To register a resource provider
Register-AzureRmResourceProvider -ProviderNamespace Microsoft.Batch