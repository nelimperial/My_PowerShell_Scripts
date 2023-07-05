<# This script will gather the Memory utilization against a single host. Use "foreach" condition/loop if you want to run this script against multiple hosts.
Define a text file as container of multiple hosts and use Get-Content cmdlet. To use extract the result use the -Append parameter.
#>
$hostname = 'hostname'       #Target host
$username = 'userid'         #System Admin account
$passwd = 'domain_password'  #Domain System Admin password
$securepasswd = ConvertTo-SecureString $passwd -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($username, $securepasswd)
#Command parameters below runs commands on a local or remote computer and returns all output from the commands.
Invoke-Command -ComputerName $hostname -Credential $credential -ScriptBlock { 
    $svrName = [System.Net.Dns]::GetHostName()
    $memRaw = Get-CimInstance Win32_OperatingSystem | Select-Object *memory*
    $memcheck = $memRaw | Select-Object  @{Name = "ServerName";Expression = {$svrName}},
    @{Name = "pctMemUsage"; Expression = {[math]::Round((($memRaw.TotalVisibleMemorySize - $memRaw.FreePhysicalMemory)/$memRaw.TotalVisibleMemorySize)*100,2)}},
    @{Name = "memFreeGB";Expression = {[math]::Round(($_.FreePhysicalMemory)/1MB,2)}},
    @{Name = "memInUseGB";Expression = {[math]::Round(($memRaw.TotalVisibleMemorySize - $memRaw.FreePhysicalMemory)/1MB,2)}},
    @{Name = "memTotalGB";Expression = {[int](($memRaw.TotalVisibleMemorySize)/1MB)}}
    $title = @"
Memory Check
-------------------------------------------------------
"@
    Write-Host $title -ForegroundColor Blue
    Write-Output $memcheck | Format-Table -Property ServerName, pctMemUsage, memFreeGB, memInUseGB, memTotalGB -AutoSize
}
