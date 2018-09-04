
# Copy managed disks in the same subscription or different subscription with PowerShell
#Provide the subscription Id of the subscription where managed disk exists
$sourceSubscriptionId='4d56d475-ad95-4ddc-a061-1a1111884730'

#Provide the name of your resource group where managed disk exists
$sourceResourceGroupName='taruntest'

#Provide the name of the managed disk
$managedDiskName='tarun_OsDisk_1_0d774cda7e694b3191b2471b429a1628'

#Set the context to the subscription Id where Managed Disk exists
Select-AzureRmSubscription -SubscriptionId $sourceSubscriptionId

#Get the source managed disk
$managedDisk= Get-AzureRMDisk -ResourceGroupName $sourceResourceGroupName -DiskName $managedDiskName

#Provide the subscription Id of the subscription where managed disk will be copied to
#If managed disk is copied to the same subscription then you can skip this step
$targetSubscriptionId='1ef3d826-ff60-4269-92c1-050346838a98'
#Name of the resource group where snapshot will be copied to
$targetResourceGroupName='resour11ce'

#Set the context to the subscription Id where managed disk will be copied to
#If snapshot is copied to the same subscription then you can skip this step
Select-AzureRmSubscription -SubscriptionId $targetSubscriptionId

$diskConfig = New-AzureRmDiskConfig -SourceResourceId $managedDisk.Id -Location $managedDisk.Location -CreateOption Copy 

#Create a new managed disk in the target subscription and resource group
New-AzureRmDisk -Disk $diskConfig -DiskName $managedDiskName -ResourceGroupName $targetResourceGroupName