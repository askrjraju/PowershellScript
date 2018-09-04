Import-Module AzureRM
$username = "rahul.singh@spectranet.in"
$password = ConvertTo-SecureString “M@chism0” -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password
Login-AzureRmAccount -Credential $cred
$AZR_Sub = Get-AzureRmSubscription
Select-AzureRmSubscription -SubscriptionId $AZR_Sub.SubscriptionId
$WL = 'WEB'
$location = 'southindia'
$rgName = $WL +'_RSG'
$vmid = '/subscriptions/976102a7-8f1b-4006-9ef5-79404ad3ac7f/resourceGroups/WEB_RSG/providers/Microsoft.Compute/virtualMachines/AZR-WBSITE-SRV'

$nic = Get-AzureRmNetworkInterface -ResourceGroupName $rgName

ForEach ($n in $nic) {
    if($n.VirtualMachine.Id -eq $vmid) {
        $nicName = $n.Name
        Remove-AzureRmNetworkInterface -ResourceGroupName $rgName -Name $n.Name
    }
}
