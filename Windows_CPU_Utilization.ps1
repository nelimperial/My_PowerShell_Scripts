<# The script below is to check/verify the current CPU utilization of the target host. Though the script will only capture a single host, but to manage multiple hosts,
use the "foreach" condition/loop and then define a text file that contains multiple hosts to gather CPU utilization.
#>
$hostname = 'target host'            ## Target host
$username = 'admin user id'          ## User ID with admin privilege
$passwd = 'domain password'          ## Domain Password
$securepasswd = ConvertTo-SecureString $passwd -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($username, $securepasswd)

### Command below to manage remotely your target host.
Invoke-Command -ComputerName $hostname -Credential $credential -ScriptBlock { 
    $cpuAvgPerf = [math]::Round((Get-Counter -Counter "\Processor(_Total)\% Processor Time" -SampleInterval 2 -MaxSamples 3 | Select-Object -ExpandProperty countersamples | Select-Object -ExpandProperty cookedvalue | Measure-Object -Average).Average,2)
$title = @"
CPU Utilization Check
----------------------------------------------------
"@
Write-Host $title -ForegroundColor Blue
Write-Output "Average of CPU usage (calculated with 5 samples with interval of 2 sec) :" $cpuAvgPerf" %"
}
