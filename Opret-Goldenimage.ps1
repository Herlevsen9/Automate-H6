# script til at oprette MASTER/Goldenimage VM, der syspreppes og andre VM'er bliver oprettet ud fra

# Link til DVD drive https://mcpmag.com/articles/2017/03/09/creating-a-vm-in-hyperv-using-ps.aspx
# Efter oprettele, følg guide for at kontrollere indstillingerne er sat, Link: https://www.vembu.com/blog/automating-hyper-v-virtual-machine-deployment-powershell/

$VMnavn = "Goldenimage"
$Sti = "$env:SystemDrive\Hyper-V\GoldenImage"
$HDDsti = "$env:SystemDrive\Hyper-V\GoldenImage\GoldenImage.vhdx"
$HDDstørrelse = 127GB
$RAMstart = 1GB
$RAMminimum = 512MB
$RAMmax = 4GB
$Cpuantal=2
$DVDsti = "$env:SystemDrive\iso\2016_x64_EN_Eval.iso"
$UnattendXML_sti = "$env:SystemDrive\Install\Scripts\autounattend.xml"
$VM_Lokaladministrator = "$VMnavn\Administrator"
$VM_Lokal_kodeord = ConvertTo-SecureString -String 'Pa$$w0rd' -AsPlainText -Force
$VMlokalcredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $VM_Lokaladministrator, $VM_Lokal_kodeord


New-VM -Name $VMnavn -Path $Sti  -MemoryStartupBytes $RAMstart  -Generation 2 -NewVHDPath $HDDsti -NewVHDSizeBytes $HDDstørrelse

# Sæt CPU
set-vm -Name $VMnavn -ProcessorCount $Cpuantal -DynamicMemory -MemoryStartupBytes $RAMstart `
-MemoryMinimumBytes $RAMminimum -MemoryMaximumBytes $RAMmax

# Tilføj DVD drev med ISO
Add-VMDvdDrive -VMName $VMnavn -Path $DVDsti

# kontroller indstillingerne

$VMNetværksadapter = Get-VMNetworkAdapter -VMName $VMnavn

$VMHarddisk = Get-VMHardDiskDrive -VMName $VMnavn

$VMDvddrev = Get-VMDvdDrive -VMName $VMnavn

# Sæt VM's bootorder til HDD, dernæst netværksadapter
Set-VMFirmware -VMname $VMnavn -BootOrder $VMHarddisk, $VMDvddrev, $VMNetværksadapter

# Sæt VM til at boote fra DVD første gang
Set-VMFirmware -VMname $VMnavn -FirstBootDevice $VMDvddrev

# Sæt VM i VLAN 20
# Get-VM -Name $VMnavn | Get-VMNetworkAdapter -Name "Network Adapter" | Set-VMNetworkAdapterVlan -Access -VlanId 20

# Enable Guest Services til VM
Enable-VMIntegrationService -VMName $VMnavn -Name "Guest Service Interface"

# Disable Checkpoints
Set-VM -Name $VMnavn -CheckpointType Disabled

# Færdiggør installation, tryk på en vilkårlig tast for acceptere boot fra DVD
vmconnect.exe $env:COMPUTERNAME $VMnavn 

Start-Sleep -Seconds 5

# Start VM
Start-VM $VMnavn

# Pause til Windows installation er færdiggjort
pause

# Sluk VM efter endt installation
Stop-VM $VMnavn

#######################
# Overfør sysprep fil #
#######################

# Hent VM navn
$VMnavn = Get-VM -Name $VMnavn | Select-Object Name -ExpandProperty name

# Sti til virtuel HDD
# $VHDsti = Get-childitem -Recurse -Path C:\HYPERV\ | Where-Object {$_.Name -match "$VMnavn.vhdx"} | Select-Object Fullname -ExpandProperty Fullname

# Mount VM virtuel HDD
Mount-VHD -Path $HDDsti

#Find drev bogstav
$VolumeDrevbogstav = Get-DISKIMAGE $HDDsti | get-disk | Get-Partition | Get-Volume | ?{$_.FilesystemLabel -ne "Recovery"} | Select-Object Driveletter -Expandproperty DriveLetter

# Destinationssti for filerne
$Fil_destination = "$VolumeDrevbogstav"+":\"

# Overfør filerne
Copy-item -Path $UnattendXML_sti -Destination $Fil_destination -force

Dismount-VHD -Path $HDDsti

# Start VM
Start-VM $VMnavn

# Vent indtil VM er klar til invoke kommandoer
 while ((Invoke-Command -VMName $VMnavn -Credential $VMlokalcredential {“Test”} -ea SilentlyContinue) -ne “Test”) {Sleep -Seconds 1}

# Kør sysprep kommando med shutdown
Invoke-Command -VMName $VMnavn -Credential $VMlokalcredential -ScriptBlock {Set-Location c:\Windows\System32\Sysprep

.\sysprep.exe /generalize /oobe /mode:vm /shutdown /unattend:C:\autounattend.xml}

# VM er ny færdig og klar til at blive clonet
