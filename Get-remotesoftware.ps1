<#
.SYNOPSIS
A simple script to check for installed software on computers in an AD environment. Results will be exported to a csv-file, offline computers to a txt-file.
Offline computers are determined by a connection test to the WINRM port. Beware of the firewall.
.DESCRIPTION
A simple script to check for installed software on computers in an AD environment.
.PARAMETER CSVLocation
location of your .csv with usernames (string)
.PARAMETER password
Provide a password for all your users in the .csv file (string)
.PARAMETER IsDisabled 
Is a switch and doesn't require input. Disables the user account on creation (or more correctly: doesn't enable it) 
.EXAMPLE
./get-remotesoftware.ps1
Runs the script and performs the tasks as explained in the SYNOPSIS
.NOTES
Author: Ken Vanden Branden
#>


if (!(Test-Path C:\ASReport))
{
New-Item c:\ASReport -ItemType directory
Write-verbose "c:\ASReport created"
}
$ADcomputer = get-adcomputer -Filter * 
$result = ForEach ($computer in $ADcomputer){
$Pingtest= Test-NetConnection $computer.Name -CommonTCPPort WINRM
    if($Pingtest.TcpTestSucceeded -eq $true)
    {
    write-verbose $computer.name
    write-verbose $pingtest.TcpTestSucceeded
    invoke-command -ComputerName $computer.name -ScriptBlock{
    Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* <# | Where-Object {$_.Publisher -eq "Microsoft Corporation"} #> | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate
    Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* <# | Where-Object {$_.Publisher -eq "Microsoft Corporation"} #> | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate
    }
    }
    else
    {
    $Offline= $computer.name | out-file C:\ASReport\offline.txt -Append
    write-verbose $computer.name
    write-verbose $pingtest.TcpTestSucceeded

    }
}
$result | where-object {$_.Displayname.length -gt 0} | Select-Object PSComputerName, DisplayName, Publisher, DisplayVersion, InstallDate | Export-Csv C:\ASReport\export.csv -NoTypeInformation