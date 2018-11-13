# Finder alle diske, der står til "raw"
Get-Disk | Where partitionstyle -eq 'raw' |

Initialize-Disk -PartitionStyle MBR -PassThru |

New-Partition -AssignDriveLetter -UseMaximumSize |

Format-Volume -FileSystem NTFS -NewFileSystemLabel "disk2" -Confirm:$false
