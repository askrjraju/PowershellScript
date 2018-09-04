Login-AzureRmAccount
Get-AzureRmSubscription
Select-AzureRmSubscription -SubscriptionId 4dd2bc4c-f9c4-4f3d-98fc-6f808be8a100

$templatesfile = ".\Azuredeploy.json"
$Parameterfile = ".\Azuredeploy.parameter.json"
New-AzureRmResourceGroupDeployment -ResourceGroupName "TestRG" -TemplateParameterFile "C:\vmss\Azuredeploy.parameter.json" -TemplateFile "C:\vmss\Azuredeploy.json"
