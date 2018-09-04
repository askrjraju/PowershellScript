$locName="south india"
Get-AzureRMVMImagePublisher -Location $locName | Select PublisherName 

$pubName="canonical"
Get-AzureRMVMImageOffer -Location $locName -Publisher $pubName | Select Offer

$offerName="ubuntuserver"
Get-AzureRMVMImageSku -Location $locName -Publisher $pubName -Offer $offerName | Select Skus