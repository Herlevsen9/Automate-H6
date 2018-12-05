# script til at oprette MASTER/Goldenimage VM, der syspreppes og andre VM'er bliver oprettet ud fra

# Prøv med VHDX boot installation istedet, copy ISO + unattend til VHDX og boot fra denne
# Link: https://gallery.technet.microsoft.com/scriptcenter/Convert-WindowsImageps1-0fe23a8f

<#
# 80 / 20 mål
# 80:
 - Opret unattend.xml kun med administrator password
 - Konverter Windows Server 2016 GUI ISO + unattend.xml til bootable .VHDX
 - Opret ny server 2016 VM med .VHDX, der booter og installere automatisk ud fra unattend.xml
 - Kontroller Powershell Direct virker efter installation
 
 # 20:
 - Konverter Windows Server 2016 Core ISO + unattend.xml til bootable .VHDX
 - Gør VM klar til SYSPREP via powershell direct
 - Overfør SYSPREP autounattend.xml til HDD
 - Kør SYSPREP kommando via powershell direct
 - Hav 2 Goldenimages, et til Server GUI og et til Server Core
#>
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

# Sluk VM efter endt installation
Stop-VM $VMnavn

# Overfør sysprep fil

# Start VM
Start-VM $VMnavn

# Kør sysprep kommando med shutdown

# VM er ny færdig og klar til at blive clonet
