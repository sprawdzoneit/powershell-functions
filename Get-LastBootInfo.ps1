#Get-LastBootInfo PowerShell function
#
#The function checks when the OS was started, collecting information about the reason for booting from the event log
#
#sprawdzone.it





function Get-LastBootInfo {

 <#
.SYNOPSIS
    The function checks when the OS was started, collecting information about the reason for booting from the event log


.NOTES
    Name: Get-LastBootInfo
    Author: sprawdzone.it
    Version: 1.1
    DateCreated: 2015-09-07


.EXAMPLE
    Get-LastBootInfo -computer ad01.sprawdzone.it
    Get-LastBootInfo -computer ad01, ad02
    $computers = get-content c:\computers.csv; Get-LastBootInfo -computer $computers


.LINK
    https://github.com/sprawdzoneit/powershell-functions
#>

[cmdletbinding()] #verbose etc.

param (
    [Parameter(
    ValueFromPipeline = $true, 
    ValueFromPipelineByPropertyName = $true,            
    Mandatory = $true,     
    Position=0,
    HelpMessage = 'Computer name')]
    [string[]]$computers #double [[]] accepts multiple string value - array
    )
    

#rune once per function
begin{ 
    Write-Verbose "Program started"
    $out = @()
}


process{
        Write-Verbose "Program runs"
        Write-Host "Getting information..." 
       $out += foreach($computer in $computers) 
                                        {
                                            if (Test-Connection -ComputerName $Computer -Count 1 -ErrorAction SilentlyContinue) {
                                                                                                Invoke-Command -ComputerName $Computer -ScriptBlock {
                                                                                                    #get hostname
                                                                                                    $hostn = hostname

                                                                                                    #get last boot time
                                                                                                    $boot = (Get-ComputerInfo).OsLastBootUpTime

                                                                                                    #get event
                                                                                                    <#
                                                                                                    Description:

                                                                                                    1074 System has been shutdown by a process/user
                                                                                                    6005 The Event log service was started
                                                                                                    6006 The Event log service was stopped
                                                                                                    6008 The previous system shutdown at time on date was unexpected
                                                                                                    6013 The system uptime is number seconds

                                                                                                    Event ID 1704 documents shut down events. 
                                                                                                    Event ID’s 6006, 6008 and 6013 document events related to a power cycle and may or may not be useful depending on your particular situation. 
                                                                                                    Pairing the 6000 events with 1074 gives a picture of how long restart operations took to complete. 
                                                                                                    6008 is important for recognizing when a computer may have blue screened or lost power unexpectedly. 
                                                                                                    6013 is not related to power cycle events, instead, it documents how long a computer has been running since the last restart. 
                                                                                                    #>
                                                                                                    $why = (Get-WinEvent -FilterHashtable @{logname = 'System'; id = 1074,6005,6006,6008} -MaxEvents 1).Message

                                                                                                    Write-Host "For $hostn last boot time is $boot with last log entry: $why"
                                                                                                                                                                                                    
                                                                                                                                                    }
                                                                                                                                            }
                                                        else { 
                                                            Write-Host "Caution: $computer is not available!"
                                                            }
                                            }
    }

#end run once per function
end{
  $out
  Write-Verbose "Function ends here"
  
}


}
