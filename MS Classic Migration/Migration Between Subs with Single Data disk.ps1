################################################ Resource Group and Storage Account ################################
Select-AzureRmSubscription -SubscriptionId c4b39a78-021e-48df-91e4-3dba53bcfaab
$ResourceGroupName = "NirfDB01"
$Location = "Central India"
$rg = Get-AzureRmResourceGroup -Name $ResourceGroupName -ErrorAction Ignore
if(!$rg)
    {
        Write-Host "Creating Resource Group"
        $rg = New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location 
   
    }

$DStorageAccName ="nirfstorageacc01"
$destCNTname = "vhds"
$StorageAcc = Get-AzureRmStorageAccount -Name $DStorageAccName -ResourceGroupName $ResourceGroupName -ErrorAction Ignore
if($StorageAcc)
{

  $destctx = $StorageAcc.Context
  $destcnt = Get-AzureStorageContainer -Name $destCNTname -Context $destctx -ErrorAction Ignore
  if(-Not $destcnt)
  {
  
     Write-Host ("Creating new container")
     $destcnt = New-AzureStorageContainer -Name $destCNTname -Context $destctx
  }


}

elseif(-Not $StorageAcc)
{
        
        Write-Host "I have to create a new storage account"
        $skuname= "Standard_GRS"
        Write-Host "Creating new Storage Account..."
        $StorageAcc = New-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $DStorageAccName -SkuName $skuname -Kind "Storage" -Location $Location
        $destctx = $StorageAcc.Context
        $destcnt = New-AzureStorageContainer -Name $destCNTname -Context $destctx
        

  }

################################################ Copy Vhd ###################################################################
Add-AzureAccount
Select-AzureSubscription -Subscriptionid f59cdd3e-dd02-45c0-8a92-e31084afaa47
$vmname = "NirfDB01"
$asvm = Get-AzureVM | Where-Object{$_.Name -like "*$vmname*"}
$csname = $asvm.ServiceName
$asmVmName = $asvm.Name
$asmVmDetails = Get-AzureVM -ServiceName $csname -Name $asmVmName
$asmStrgName = (($asmVmDetails.VM.OSVirtualHardDisk.MediaLink.Authority).Split("."))[0]
$srcContext = (Get-AzureStorageAccount -StorageAccountName $asmStrgName).Context
$srcvhd = $asmVmDetails.vm.OSVirtualHardDisk.MediaLink.AbsoluteUri
#Stop-AzureVM -Name $vmname -ServiceName $csname -Force
$destvhdname = $asmVmDetails.VM.OSVirtualHardDisk.DiskName + ".vhd" 

$blob1 = Start-AzureStorageBlobCopy -Context $srcContext –AbsoluteUri $srcvhd –DestContainer $destCNTname –DestBlob $destvhdname –DestContext $destctx -Verbose
$j=1
for($i=0;$i -lt $j;$i++)
   {
      $status = $blob1 | Get-AzureStorageBlobCopyState
      $Gbcpy = $status.BytesCopied/1GB
      $Gbleft = $status.TotalBytes/1GB
      Write-Host "Data Copied:" $Gbcpy "GB"
      Write-Host "Total Data:" $Gbleft "GB"
      sleep(300)
      if($status.Status -eq "Success" )
        {

############################################### virtual network and subnet #############################################
$VnetName = "NIRFNet"
$vnet = Get-AzureRmVirtualNetwork -Name $VnetName -ResourceGroupName "Nirf-Vnet" -ErrorAction Ignore
if(!$vnet)
     {
     
       $vnetaddress = "192.168.0.0/24"
       Write-Host "Creating a new virtual network"   
       $vnet = New-AzureRmVirtualNetwork -Name $VnetName -ResourceGroupName $ResourceGroupName -Location $Location -AddressPrefix $vnetaddress
    
     }
       $subnetname = "Subnet-1"
       $subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name $subnetname -VirtualNetwork $vnet -ErrorAction Ignore
if(!$subnet)
     {
       $subnetaddress = "192.168.0.0/27"  
       Write-Host "Creating new subnet"
       $subnet = Add-AzureRmVirtualNetworkSubnetConfig -Name $subnetname -VirtualNetwork $vnet -AddressPrefix $subnetaddress
       $a = Set-AzureRmVirtualNetwork -VirtualNetwork $vnet
       $vnet = Get-AzureRmVirtualNetwork -Name $VnetName -ResourceGroupName $ResourceGroupName -ErrorAction Ignore
     }   
############################################# Ip and Nic #####################################################
$NicName = $vmname + "-nic"

Write-Host "Creating NIC"
$SubnetID = (Get-AzureRmVirtualNetworkSubnetConfig -Name $subnetname -VirtualNetwork $vnet).Id
$Nic=New-AzureRmNetworkInterface -Name $NicName -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $SubnetID -PrivateIpAddress 192.168.0.5

    

    

########################################################## VM config########################################
$vmsize = $asmVmDetails.InstanceSize

$os = $asmVmDetails.VM.OSVirtualHardDisk.OS
$vmConfig = New-AzureRmVMConfig -VMName $vmname -VMSize $vmsize 

################################Add the NIC##############################################

$vm = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $Nic.Id

$osDiskUri = (Get-AzureStorageBlob -Blob $destvhdname -Container $destCNTname -Context $destctx).ICloudBlob.Uri.AbsoluteUri 
if($os -eq "windows")
{

$vm = Set-AzureRmVMOSDisk -VM $vm -Name $destvhdname -VhdUri $osDiskUri -CreateOption attach -Windows

}
elseif($os -eq "linux")
{

$vm = Set-AzureRmVMOSDisk -VM $vm -Name $destvhdname -VhdUri $osDiskUri -CreateOption attach -Linux 

}

#########################################Create VM###########################################################
Write-Host "Creating Virtual Machine in ARM"
New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $vm 
}
else
    {
        
        $j++
    }
}
Stop-AzureRmVM -Name $vmname -ResourceGroupName $ResourceGroupName -Force
######################################Copy Data Disks To VM##############################################
$vm = Get-AzureVM -Name $asmVmName -ServiceName $csname
$dddata = Get-AzureDataDisk -VM $vm 
if($dddata.Count -eq 0)
{
  Write-host "Successfully Migrated Virtual Machine"
}
else
{
$ddcntname = "vhds"
$ddisksize = $dddata.LogicalDiskSizeInGB
$lun = $dddata.Lun
$dd = Get-AzureDataDisk -VM $vm 
$ddnames = $dd.DiskName
for($i=0;$i -lt $ddnames.Count;$i++ )
{
$srcdduri = $dd.MediaLink.AbsoluteUri
$destddname = $ddnames +".vhd"
$ddCpy = Start-AzureStorageBlobCopy -Context $srcContext –AbsoluteUri $srcdduri –DestContainer $ddcntname –DestBlob $destddname –DestContext $destctx -Verbose

        $j=1
        for($k=0;$k -lt $j;$k++)
        {
      $status = $ddCpy | Get-AzureStorageBlobCopyState
      $Gbcpy = $status.BytesCopied/1GB
      $Gbleft = $status.TotalBytes/1GB
      Write-Host "Data Copied:" $Gbcpy "GB"
      Write-Host "Total Data:" $Gbleft "GB"
      sleep(300)
        if($status.Status -eq "Success" )
            {
    
             Write-Host "Successfully Copied the VHD" $ddnames[$i]
             $ddblob = Get-AzureStorageBlob -Container $ddcntname -Context $destctx -Blob $destddname 
             $DDiskUri = $ddblob.ICloudBlob.Uri.AbsoluteUri
             $vmdiskadd = Get-AzurermVM -ResourceGroupName $ResourceGroupName -Name $vmname
             Add-AzureRMVMDataDisk -Name $destddname -VM $vmdiskadd -VhdUri $DDiskUri -LUN $lun[$i] -Caching None -CreateOption Attach -DiskSizeInGB $ddisksize[$i] -ErrorAction Ignore
             Update-AzureRmVM -ResourceGroupName $ResourceGroupName -VM $vmdiskadd
            }
        else
            {
                
                $j++
            }

         }
}
}
#################################################### Attach data disks to vm #############################################################

<#$ddblob = Get-AzureStorageBlob -Container $ddcntname -Context $destctx 
$ddblobnames = $ddblob.Name
for($d=0;$d -lt $ddblobnames.Count ; $d++)
{
$DDiskUri = $ddblob.ICloudBlob.Uri.AbsoluteUri[$d]
$vmdiskadd = Get-AzurermVM -ResourceGroupName $ResourceGroupName -Name $vmname
Add-AzureRMVMDataDisk -Name $ddblobnames[$d] -VM $vmdiskadd -VhdUri $DDiskUri -LUN $d -Caching None -CreateOption Attach -DiskSizeInGB $ddisksize[$d] -ErrorAction Ignore
Update-AzureRmVM -ResourceGroupName $ResourceGroupName -VM $vmdiskadd
}
Write-Host "Successfully Moved Virtual Machine From ASM to ARM"#>

