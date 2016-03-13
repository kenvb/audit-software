#This script gets all the Computers in the AD and then gets all the software installed on those computers.
$ADcomputer = get-adcomputer -Filter * 
$result = ForEach ($computer in $ADcomputer){

$Pingtest= Test-NetConnection $computer.Name
    if($Pingtest.Pingsucceeded -eq $true)
    {
    write-host $computer.name
    write-host $pingtest.PingSucceeded
    invoke-command -ComputerName $computer.name -ScriptBlock{
    Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* <# | Where-Object {$_.Publisher -eq "Microsoft Corporation"} #> | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate
    }
    }
    else
    {
    write-host $computer.name
    write-host $pingtest.PingSucceeded
    }
}
$result | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate,PSComputerName | Export-Csv C:\drivers\export.csv