#Provide the subscription Id 
 $subscriptionId = 'b3500821-1bbb-4053-a716-a38f4e26aa16' 

#Provide the name of your resource group 
$resourceGroupName ='manage_rg' 
  #Provide the name of the snapshot that will be used to create Managed Disks 
   $snapshotName = 'md-snap' 

#Provide the name of the Managed Disk 
 $diskName = 'my_disk'  
 
 #Provide the size of the disks in GB. It should be greater than the VHD file size. 
 $diskSize = '128' 
 
 
 #Provide the storage type for Managed Disk. PremiumLRS or StandardLRS. 
 $storageType = 'StandardLRS' 
 
 
 #Provide the Azure region (e.g. westus) where Managed Disks will be located. 
 #This location should be same as the snapshot location 
 #Get all the Azure location using command below: 
 #Get-AzureRmLocation 
 $location = 'Southeast Asia' 
 <# create a vm with managed disk, take snap shot of that vm and make a disk from snapshot using below command. Now we can able to create a vm from this disk using portal or powershell#>

 #Set the context to the subscription Id where Managed Disk will be created 
 Select-AzureRmSubscription -SubscriptionId $SubscriptionId 
 
 
$snapshot = Get-AzureRmSnapshot -ResourceGroupName $resourceGroupName -SnapshotName $snapshotName  
  
$diskConfig = New-AzureRmDiskConfig -AccountType $storageType -Location $location -CreateOption Copy -SourceResourceId $snapshot.Id 
   
 New-AzureRmDisk -Disk $diskConfig -ResourceGroupName $resourceGroupName -DiskName $diskName
