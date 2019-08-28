# script til at oprette MASTER/Goldenimage VM, der syspreppes og andre VM'er bliver oprettet ud fra
[String]$VMnavn = "Goldenimage2016"
$Sti =Get-VMHost | Select-Object VirtualMachinePath -ExpandProperty VirtualMachinePath
$HDDsti = $Sti + $VMnavn +"\" + $VMnavn + ".vhdx"
$HDDstørrelse = 127GB
$RAMstart = 1GB
$RAMminimum = 512MB
$RAMmax = 4GB
$Cpuantal=2
$DVDsti = "$env:SystemDrive\iso\Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.ISO"
$UnattendXML_sti = "$env:SystemDrive\Scripts\autounattend_2016.xml"
$VM_Lokaladministrator = "$VMnavn\Administrator"
$VM_Lokal_kodeord = ConvertTo-SecureString -String 'Pa$$w0rd' -AsPlainText -Force
$VMlokalcredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $VM_Lokaladministrator, $VM_Lokal_kodeord

New-VM -Name $VMnavn -Path $Sti  -MemoryStartupBytes $RAMstart  -Generation 2 -NewVHDPath $HDDsti -NewVHDSizeBytes $HDDstørrelse

# Sæt CPU, Dynamisk memory, memory til startup, minimum og maximum ram
set-vm -Name $VMnavn -ProcessorCount $Cpuantal -DynamicMemory -MemoryStartupBytes $RAMstart `
-MemoryMinimumBytes $RAMminimum -MemoryMaximumBytes $RAMmax

# Tilføj DVD drev med ISO
Add-VMDvdDrive -VMName $VMnavn -Path $DVDsti

$VMNetværksadapter = Get-VMNetworkAdapter -VMName $VMnavn

$VMHarddisk = Get-VMHardDiskDrive -VMName $VMnavn

$VMDvddrev = Get-VMDvdDrive -VMName $VMnavn

# Sæt VM's bootorder til HDD, DVD drev og derefter netværksadapter
Set-VMFirmware -VMname $VMnavn -BootOrder $VMHarddisk, $VMDvddrev, $VMNetværksadapter

# Sæt VM til at boote fra DVD første gang
Set-VMFirmware -VMname $VMnavn -FirstBootDevice $VMDvddrev

# Sæt VM i VLAN 101
Get-VM -Name $VMnavn | Get-VMNetworkAdapter -Name "Network Adapter" | Set-VMNetworkAdapterVlan -Access -VlanId 101

# Enable Guest Services til VM
Enable-VMIntegrationService -VMName $VMnavn -Name "Guest Service Interface"

# Disable Checkpoints
Set-VM -Name $VMnavn -CheckpointType Disabled

vmconnect.exe $env:COMPUTERNAME $VMnavn 

Start-Sleep -Seconds 5

# Start VM
Start-VM $VMnavn

# Færdiggør installation, tryk på en vilkårlig tast for acceptere boot fra DVD

# Pause til Windows installation er færdiggjort
pause

# Sluk VM efter endt installation
Stop-VM $VMnavn

# Mount VM virtuel HDD
Mount-VHD -Path $HDDsti

#Find drev bogstav
$VolumeDrevbogstav = Get-DISKIMAGE $HDDsti | get-disk | Get-Partition | Get-Volume | ?{$_.FilesystemLabel -ne "Recovery"} | Select-Object Driveletter -Expandproperty DriveLetter

# Destinationssti for fil
$Fil_destination = "$VolumeDrevbogstav"+":\autounattend.xml"

# Overfør filerne
Copy-item -Path $UnattendXML_sti -Destination $Fil_destination

Dismount-VHD -Path $HDDsti

# Start VM
Start-VM $VMnavn
