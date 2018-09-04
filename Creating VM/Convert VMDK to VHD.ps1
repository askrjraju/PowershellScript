Install Microsoft virtul machine converter (https://www.microsoft.com/en-my/download/confirmation.aspx?id=42497)

Import-Module 'C:\Program Files\Microsoft Virtual Machine Converter\MvmcCmdlet.psd1'
ConvertTo-MvmcVhd -SourceLiteralPath "C:\vmdk\xenial-server-cloudimg-amd64-disk1.vmdk" -DestinationLiteralPath "C:\temp'\centOs.vhd"-VhdType FixedHardDisk -VhdFormat Vhd

# Upload VHD
Add-AzureRmVhd -ResourceGroupName "TestRg" -Destination "https://uploadvmstg.blob.core.windows.net/vhds/CentOs.vhd" -LocalFilePath 'C:\Temp1\centOs.vhd.vhd'

ConvertTo-MvmcVhd -SourceLiteralPath "C:\vmdk\CentOSconverted.vhdx" -DestinationLiteralPath "C:\vmdk\Ubuntuvm.vhd" -VhdType FixedHardDisk -VhdFormat Vhd