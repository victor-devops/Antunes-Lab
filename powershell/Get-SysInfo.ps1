Write-Output ("Hostname: {0}" -f $env:COMPUTERNAME)
Write-Output ("OS: {0}" -f (Get-CimInstance Win32_OperatingSystem).Caption)
