# script til at oprette MASTER/Goldenimage VM, der syspreppes og andre VM'er bliver oprettet ud fra

# Link til Lab oprettelse: https://blogs.msmvps.com/russel/category/hyper-v/

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
-MemoryMinimumBytes $RAMminimum -MemoryMaximumBytes $RAMmax

# kontroller indstillingerne

#
# Mangler at indsætte et DVD drev
#

# Indsæt ISO i DVD drev
Set-VMDvdDrive -VMName $VMnavn -Path $DVDsti

# Find syntaks i denne guide: http://itproctology.blogspot.com/2013/10/modifying-hyper-v-generation2-vm-boot.html
# Sæt VM til at boote fra DVD
Set-VMFirmware $VMnavn -FirstBootDevice 

# Start VM
Start-VM $VMnavn

# Færdiggør installation

# Sluk VM
Stop-VM $VMnavn

# Overfør sysprep fil

# Start VM
Start-VM $VMnavn

# Kør sysprep kommando med shutdown

# VM er ny færdig og klar til at blive clonet
