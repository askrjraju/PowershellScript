Install Microsoft virtul machine converter (https://www.microsoft.com/en-my/download/confirmation.aspx?id=42497)

Import-Module 'C:\Program Files\Microsoft Virtual Machine Converter\MvmcCmdlet.psd1'
ConvertTo-MvmcVhd -SourceLiteralPath "C:\vmdk\xenial-server-cloudimg-amd64-disk1.vmdk" -DestinationLiteralPath "C:\vmdk\CentOSconverted.vhdx" -VhdType FixedHardDisk -VhdFormat Vhdx 