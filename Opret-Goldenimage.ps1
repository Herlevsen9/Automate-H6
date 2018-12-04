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
$DVDsti = "$env:SystemDrive\iso\SW_DVD9_Win_Pro_Ent_Edu_N_10_1803_64BIT_English_-3_MLF_X21-82160.ISO"

New-VM -Name $VMnavn -Path $Sti  -MemoryStartupBytes $RAMstart  -Generation 2 -NewVHDPath $HDDsti -NewVHDSizeBytes $HDDstørrelse

# Sæt CPU
set-vm -Name $VMnavn -ProcessorCount $Cpuantal -DynamicMemory -MemoryStartupBytes $RAMstart `
-MemoryMinimumBytes $RAMminimum -MemoryMaximumBytes $RAMmax -

# kontroller indstillingerne

# Tilføj DVD drev med ISO
Add-VMDvdDrive -VMName $VMnavn -Path $DVDsti


# Find syntaks i denne guide: http://itproctology.blogspot.com/2013/10/modifying-hyper-v-generation2-vm-boot.html

$VMNetværksadapter = Get-VMNetworkAdapter -VMName $VMnavn

$VMHarddisk = Get-VMHardDiskDrive -VMName $VMnavn

$VMDvddrev = Get-VMDvdDrive -VMName $VMnavn

# Sæt VM's bootorder til HDD, dernæst netværksadapter
Set-VMFirmware -VMname $VMnavn -BootOrder $VMHarddisk, $VMDvddrev, $VMNetværksadapter

Get-VMFirmware $VMnavn | select * | Sort-Object

# Sæt VM til at boote fra DVD første gang
Set-VMFirmware -VMname $VMnavn -FirstBootDevice $VMDvddrev

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
