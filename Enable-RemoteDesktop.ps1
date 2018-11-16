<#
.Synopsis
   Enable RemoteDesktop on a remote computer via Powershell Remoting
.DESCRIPTION
   Sets the Registry keys to allow Remotedesktop connections and adds a firewall rule to allow remotedesktop connections
   There has to be passed credentials, that have administrative rights on the computer

.NOTES
   General notes
   Author: Steffen Herlevsen
   Version: 1.0
   CreationDate: 16.11.2018
   Save it as "Enable-RemoteDesktop.psm1"  in "%ProgramFiles%\WindowsPowerShell\Modules\Enable-RemoteDesktop\" to have it automatically loaded in powershell

.EXAMPLE
   Enable-RemoteDesktop -computername "CL1" -credentials (get-credentials)
.EXAMPLE
   Enable-RDP -computername "CL2","CL3","SRV1"
#>
function Enable-RemoteDesktop
{
    [CmdletBinding()]
    [Alias("CN","Enable-RDP")]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   HelpMessage="Enter one or more computer names separated by commas.",
                   Position=0)]
        [String[]]
        $ComputerName,

        # Param2 help description
        [Parameter(Mandatory=$true,
                      Position=1)]
        $Credentials = (Get-Credential)
    )
        
    Process
    {
    invoke-command -ComputerName $ComputerName -Credential $Credentials -ScriptBlock {
    
    # Enable Remote Desktop connections
    Set-ItemProperty ‘HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\‘ -Name “fDenyTSConnections” -Value 0

    # Enable Network Level Authentication
    Set-ItemProperty ‘HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\‘ -Name “UserAuthentication” -Value 1

    # Enable Windows firewall rules to allow incoming RDP
    Enable-NetFirewallRule -DisplayGroup “Remote Desktop”
    
    }
    }
    
}
