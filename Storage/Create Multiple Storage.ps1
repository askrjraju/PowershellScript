$NumberOfStorage = 2;
$ResourceGroupName = "DLVRG"
$Location = "southindia"
$StorageName = "dlvrgstg01"
$StorageType = "Standard_LRS"
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location

$i = 1;

Do 
{ 
    $i; 
    $stname ="dlvstg01"+$i
    $staccount = New-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $stname -SkuName Standard_LRS -Location $Location -Kind Storage 
    $i +=1
} 
Until ($i -gt $NumberOfStorage)
$staccount = Get-AzureRmStorageAccount | Where-Object {$_.ResourceGroupName -eq "DLVRG"}




