# Skal laves til en funktion

<#
.Synopsis
   Opretter ny VM
.DESCRIPTION
   Cloner GoldenImage, definere indstillinger i VM og Windows via autounattend.xml
.EXAMPLE
   Clone-VM 
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function Clone-VM
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([String])]
    Param
    (
        # VMnavn hjælpe beskrivelse
        # Validatescript kontrollere at VMnavn ikke findes i forvejen
        [Parameter(Mandatory=$true, 
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern("[a-z]*")]
        [ValidateLength(0,15)]
        [ValidateScript({(Get-VM | select Name -Expandproperty Name) -notcontains $_})] 
        [String] 
        $VMnavn,

        # CpuCount hjælpe beskrivelse
        [Parameter()]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateRange(1,5)]
        [Int]
        $CpuCount=2,

        # RAMCount hjælpe beskrivelse, 32GB er max tilladt RAM
        [Parameter()]
        [ValidateRange(1,32)]
        [Int]
        $RAMCount=1GB,

        # IPDomain hjælpe beskrivelse
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]
        $IPDomain,

         # DefaultGW hjælpe beskrivelse
        [Parameter()]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]
        $DefaultGW="10.12.14.1",

         # DNSServer hjælpe beskrivelse
        [Parameter()]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]
        $DNSServer="10.12.14.5,10.12.14.6",
        
        # DNSDomain hjælpe beskrivelse
        [Parameter()]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]
        $DNSDomain="AD.SPECEROPS.DK",

        # SwitchNameDomain hjælpe beskrivelse
        [Parameter()]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]
        $SwitchNameDomain="ExternalSwitch",

        # NetworkAdapterName hjælpe beskrivelse
        [Parameter()]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]
        $NetworkAdapterName="NIC1",

        # AdminAccount hjælpe beskrivelse
        [Parameter()]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]
        $AdminAccount="Administrator",

        # AdminAccount hjælpe beskrivelse
        [Parameter()]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]
        $AdminPassword='Pa$$w0rd',

        # AdminAccount hjælpe beskrivelse
        [Parameter()]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]
        $Organization="Specterops",

        # AdminAccount hjælpe beskrivelse
        [Parameter()]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]
        $ProductID="TMJ3Y-NTRTM-FJYXT-T22BY-CWG3J",

        #Where's the VM Default location? You can also specify it manually
        $Path= (Get-VMHost |select VirtualMachinePath -ExpandProperty VirtualMachinePath),
        # Virtuel HDD sti
        $VHDPath=$Path + $VMnavn + "\" + $VMnavn + ".vhdx",
        # Foldere til automationsfiler
        $StartupFolder="$env:SystemDrive\HyperV",
        $TemplateLocation="$env:SystemDrive\HyperV\GoldenImage\GoldenImage.vhdx",
        $UnattendLocation="$env:SystemDrive\Install\Scripts\autounattend.xml"

    )

    Begin
    {
    #Opret VM
    New-VM -Name $VMnavn -Path $Path  -MemoryStartupBytes $RAMCount  -Generation 2 -NoVHD

    # Fjern de autogenerede netværksadaptere 
    Get-VMNetworkAdapter -VMName $VMnavn |Remove-VMNetworkAdapter
    # Tilføj en ny med det korrekte navn
    Add-VMNetworkAdapter -VMName $VMnavn -SwitchName $SwitchNameDomain -Name $NetworkAdapterName -DeviceNaming On

    # Start og stop VM for at få MAC adresse, sæt den herefter på selve netværksadapteren
    start-vm $VMnavn
    sleep 5
    stop-vm $VMnavn -Force
    sleep 5
    $MACAddress=get-VMNetworkAdapter -VMName $VMnavn -Name $NetworkAdapterName|select MacAddress -ExpandProperty MacAddress
    $MACAddress=($MACAddress -replace '(..)','$1-').trim('-')
    get-VMNetworkAdapter -VMName $VMnavn -Name $NetworkAdapterName|Set-VMNetworkAdapter -StaticMacAddress $MACAddress
     
    #Copy the template and add the disk on the VM. Also configure CPU and start - stop settings
    Copy-item $TemplateLocation -Destination  $VHDPath
    Set-VM -Name $VMnavn -ProcessorCount $CpuCount  -AutomaticStartAction Start -AutomaticStopAction ShutDown -AutomaticStartDelay 5 
    Add-VMHardDiskDrive -VMName $VMnavn -ControllerType SCSI -Path $VHDPath
     
    #Set first boot device to the disk we attached
    $Drive=Get-VMHardDiskDrive -VMName $VMnavn | where {$_.Path -eq "$VHDPath"}
    Get-VMFirmware -VMName $VMnavn | Set-VMFirmware -FirstBootDevice $Drive

    }
    Process
    {
    #Prepare the unattend.xml file to send out, simply copy to a new file and replace values
    Copy-Item $UnattendLocation $StartupFolder\"unattend"$VMnavn".xml"
    $DefaultXML=$StartupFolder+ "\unattend"+$VMnavn+".xml"
    $NewXML=$StartupFolder + "\unattend$VMnavn.xml"
    $DefaultXML=Get-Content $DefaultXML
    $DefaultXML  | Foreach-Object {
     $_ -replace '1AdminAccount', $AdminAccount `
     -replace '1Organization', $Organization `
     -replace '1Name', $VMnavn `
     -replace '1ProductID', $ProductID`
     -replace '1MacAddressDomain',$MACAddress `
     -replace '1DefaultGW', $DefaultGW `
     -replace '1DNSServer', $DNSServer `
     -replace '1DNSDomain', $DNSDomain `
     -replace '1AdminPassword', $AdminPassword `
     -replace '1IPDomain', $IPDomain `
     } | Set-Content $NewXML
     
    #Mount the new virtual machine VHD
    mount-vhd -Path $VHDPath
    #Find the drive letter of the mounted VHD
    $VolumeDriveLetter=GET-DISKIMAGE $VHDPath | GET-DISK | GET-PARTITION |get-volume |?{$_.FileSystemLabel -ne "Recovery"}|select DriveLetter -ExpandProperty DriveLetter
    #Construct the drive letter of the mounted VHD Drive
    $DriveLetter="$VolumeDriveLetter"+":"
    #Copy the unattend.xml to the drive
    Copy-Item $NewXML $DriveLetter\unattend.xml
    #Dismount the VHD
    Dismount-Vhd -Path $VHDPath
       
    }
    End
    {
    
    #Fire up the VM
    Start-VM $VMnavn

    }
}

 

 
