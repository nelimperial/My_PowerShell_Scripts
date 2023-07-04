<### This script will automate the process to shutdown gracefully in vCenter for decommissioning process.
Upon powering off the target VMs, it will automate the process to move the powered off VMs to specific folder "ToBeDecommissioned" in vCenter.
###>

$username = 'username'                          ## This is your domain user id
$passwd = 'system admin password'               ## Your system admin password
$vcenter = 'vCenter server'                     ## This is the VCenter server of your Organization
Connect-VIServer -Server $vcenter -User $username -Password $passwd
$vm_list = Get-Content "C:\Temp\VMServers.txt"  ## This is the folder path of your list of servers to decom
$label = "label name of your preference"        ## This is the naming convention to be attached to your VMs to be renamed
$renamedVM = "C:\Temp\RenamedVMs.txt"           ## This is the folder path of the renamed VMs
##### The commands below will rename the VM name of the Guest OS in vCenter
foreach ($_ in $vm_list) { 
    Get-VM -Name $_ | Set-VM -Name "$_ $label" -Confirm:$false
}

##### Get the new VM name of the renamed Guest OS
foreach ($_ in $vm_list) {
    Get-VM -Name $_* | Select-Object Name | Format-Table -Property Name -HideTableHeaders | Out-File -Path $renamedVM -Append
}

##### The commands below will Power off the Guest OS upon renaming in vCenter.
$vm_renamed_list = Get-Content $renamedVM | Where-Object {$_ -ne ""} > "C:\Temp\RenamedVMsWithNoEmptyLines.txt"
$RenamedVMwithEmptyLines = Get-Content "C:\Temp\RenamedVMsWithNoEmptyLines.txt"
foreach ($VMsOff in $RenamedVMwithEmptyLines) { 
    Shutdown-VMGuest -VM $VMsOff -Confirm:$false
}

##### The commands below will move the Powered off VMs to the "ToBeDecommissioned" folder in vCenter
$RenamedVMwithEmptyLines = Get-Content "C:\Temp\RenamedVMsWithNoEmptyLines.txt"
foreach ($_ in $RenamedVMwithEmptyLines) {
    Move-VM -VM $_ -Destination ToBeDecommissioned
}
