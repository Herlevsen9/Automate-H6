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

New-VM -Name $VMnavn -Path $Sti  -MemoryStartupBytes $RAMstørrelse  -Generation 2 -NewVHDPath $HDDsti -NewVHDSizeBytes $HDDstørrelse

# Sæt CPU
Get-VM -Name $VMnavn | Set-VM -ProcessorCount $Cpuantal -DynamicMemory $True -MemoryStartupBytes $RAMstart `
-MemoryMinimumBytes $RAMminimum -MemoryMaximumBytes $RAMmax

# kontroller indstillingerne

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
