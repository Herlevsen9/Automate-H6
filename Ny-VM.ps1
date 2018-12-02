# Skal laves til en funktion

# Specifikationer til VM'en
#Cpu Cores
$CpuCount=2
#Ram Størrelse
$RAMCount=1GB
#VMNavn , vil også blive til OSnavn
$Name="Test"
#IP Addresse
$IPDomain="192.168.0.10"
#Default Gateway
$DefaultGW="192.168.0.254"
#DNS Server
$DNSServer="192.168.0.1"
#DNS Domain Name
$DNSDomain="LME.DK"
#Hyper V Switch Navn
$SwitchNameDomain="ExternalSwitch"
#Netværksadapternavn
$NetworkAdapterName="NIC1"
#Brugernavn og kodeord
$AdminAccount="Administrator"
$AdminPassword="P@ssw0rd"
#Organisationsinformation
$Organization="Logging Made Easy"
#This ProductID is actually the AVMA key provided by MS
$ProductID="TMJ3Y-NTRTM-FJYXT-T22BY-CWG3J"
#Where's the VM Default location? You can also specify it manually
$Path= Get-VMHost |select VirtualMachinePath -ExpandProperty VirtualMachinePath
# Virtuel HDD sti
$VHDPath=$Path + $Name + "\" + $Name + ".vhdx"
# Foldere til automationsfiler
$StartupFolder="$env:SystemDrive\HyperV"
$TemplateLocation="$env:SystemDrive\Hyper-V\GoldenImage\GoldenImage.vhdx"
$UnattendLocation="$env:SystemDrive\Hyper-V\GoldenImage\unattend.xml"
 
#Part 1 færdig-------------------------------------------------------------------------------#
 
#Part 2 Initialize---------------------------------------------------------------------------------#
#Kontroller om VMnavn findes i forvejen, hvis der er skal brugeren blot informeres
$VMS=Get-VM
Foreach($VM in $VMS)
{
 if ($Name -match $VM.Name)
 {
 Write-Output "VM navn findes i forvejen" -InformationAction Stop
 $Found=$True
 }
}
 
#Opret VM
New-VM -Name $Name -Path $Path  -MemoryStartupBytes $RAMCount  -Generation 2 -NoVHD

# Fjern de autogenerede netværksadaptere og tilføj en ny med det korrekte navn
Get-VMNetworkAdapter -VMName $Name |Remove-VMNetworkAdapter
Add-VMNetworkAdapter -VMName $Name -SwitchName $SwitchNameDomain -Name $NetworkAdapterName -DeviceNaming On
 
# Start og stop VM for at få MAC adresse, sæt den herefter på selve netværksadapteren
start-vm $Name
sleep 5
stop-vm $Name -Force
sleep 5
$MACAddress=get-VMNetworkAdapter -VMName $Name -Name $NetworkAdapterName|select MacAddress -ExpandProperty MacAddress
$MACAddress=($MACAddress -replace '(..)','$1-').trim('-')
get-VMNetworkAdapter -VMName $Name -Name $NetworkAdapterName|Set-VMNetworkAdapter -StaticMacAddress $MACAddress
 
#Copy the template and add the disk on the VM. Also configure CPU and start - stop settings
Copy-item $TemplateLocation -Destination  $VHDPath
Set-VM -Name $Name -ProcessorCount $CpuCount  -AutomaticStartAction Start -AutomaticStopAction ShutDown -AutomaticStartDelay 5 
Add-VMHardDiskDrive -VMName $Name -ControllerType SCSI -Path $VHDPath
 
#Set first boot device to the disk we attached
$Drive=Get-VMHardDiskDrive -VMName $Name | where {$_.Path -eq "$VHDPath"}
Get-VMFirmware -VMName $Name | Set-VMFirmware -FirstBootDevice $Drive
 
#Prepare the unattend.xml file to send out, simply copy to a new file and replace values
Copy-Item $UnattendLocation $StartupFolder\"unattend"$Name".xml"
$DefaultXML=$StartupFolder+ "\unattend"+$Name+".xml"
$NewXML=$StartupFolder + "\unattend$Name.xml"
$DefaultXML=Get-Content $DefaultXML
$DefaultXML  | Foreach-Object {
 $_ -replace '1AdminAccount', $AdminAccount `
 -replace '1Organization', $Organization `
 -replace '1Name', $Name `
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
#Fire up the VM
Start-VM $Name
