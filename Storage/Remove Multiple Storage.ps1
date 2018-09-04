$NumberOfStorage = 2;
$i = 1;

Do 
{ 
    $i; 
    $stname ="dlvstg01"+$i
    $staccount = Remove-AzureRmStorageAccount -ResourceGroupName "DLVRG" -Name $stname 
    $i +=1
} 
Until ($i -gt $NumberOfStorage)