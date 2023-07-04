$hostname = 'hostname'       #Target host
$username = 'userid'         #System Admin account
$passwd = 'domain_password'  #Domain System Admin password
$securepasswd = ConvertTo-SecureString $passwd -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($username, $securepasswd)
Invoke-Command -ComputerName $hostname -Credential $credential -ScriptBlock { 
    $disksRaw = Get-CimInstance Win32_LogicalDisk #| Select-Object "PSComputerName", "DeviceID", "VolumeName", "Size", "FreeSpace" | Format-Table
    $disksUsage = Get-CimInstance Win32_LogicalDisk | Select-Object @{Name = "Server Name";Expression = {$_.SystemName}},
    @{Name = "Volume";Expression = {$_.DeviceID}},
    @{Name = "Capacity (GB)";Expression = {[math]::Round($_.Size/1gb)}},
    @{Name = "Free Space (GB)";Expression = {[math]::Round($_.FreeSpace/1gb,2)}},
    @{Name = "% Free";Expression = {[math]::Round(($_.FreeSpace/$_.Size)*100)}}
    
    $title = @"
Volume Drives Check
-------------------------------------------------------
"@
    Write-Host $title -ForegroundColor Blue
    Write-Output $disksUsage | Format-Table -AutoSize
}
