# Aktiver Hyper feature med services og tools
Install-WindowsFeature -Name Hyper-V -IncludeManagementTools -Restart

Get-NetAdapter 

# Opret ekstern vSwitch
New-VMSwitch -name ExternalSwitch  -NetAdapterName Ethernet -AllowManagementOS $true  

# Opret intern vSwitch
New-VMSwitch -name InternSwitch -SwitchType Internal  
