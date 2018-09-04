#variable creation
$rgName = "firstprodRG"
    

#path to destination

$urlOfUploadedImageVhd = "https://generalstorageudhay.blob.core.windows.net/vhds/ponk.vhd"
    

Add-AzureRmVhd -ResourceGroupName $rgName -Destination $urlOfUploadedImageVhd -LocalFilePath c:\ponk.vhd