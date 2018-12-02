# Bruges til fx. Filserver når der indsættes en datadisk

# Mulige variabler
[Parameter(Mandatory=$true,
Position=0)]
$VMnavn,
[Parameter(Mandatory=$true,
Position=1)]
$HDDstørrelse,
[Parameter(Mandatory=$true,
Position=2)]
$Filsystemlabel,
[Parameter(Mandatory=$false)]
$Filformat="NTFS",
[Parameter(Mandatory=$false)]
$Drevbogstav

# Opret ny VHDX, sæt størrelse (fx. 100GB)

# Tilføj til VM

# Finder alle diske, der står til "raw"
Get-Disk | Where partitionstyle -eq 'raw' |

Initialize-Disk -PartitionStyle MBR -PassThru |

New-Partition -AssignDriveLetter -UseMaximumSize |

Format-Volume -FileSystem $Filformat -NewFileSystemLabel $Filsystemlabel -Confirm:$false
