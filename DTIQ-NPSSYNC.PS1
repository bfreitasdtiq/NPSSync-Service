<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	4/27/2021 10:44 PM
	 Created by:   	Brysen Freitas
	 Organization: 	DTIQ
	 Filename:     	
	===========================================================================
	.DESCRIPTION
		Automated NPS Copy script made with Powershell. This script is used to copy NPS configurations from one NPS to another.
#>
$SettingsNPSSYNC = Get-Content -Path 'C:\dtiq\settings\NPSSYNC-Settings.json' | ConvertFrom-Json
$NPSDestServer = $SettingsNPSSYNC.NPSDEST
$restart = $SettingsNPSSYNC.restarttimeseconds


#Loop
do
{
	# Get date
	$date = get-date -Format yyyy_MM_dd
	# Export NPS config
	Export-NpsConfiguration -Path C:\dtiq\NPS\NPSConfig_$date.xml
	Export-NpsConfiguration -Path C:\dtiq\NPS\NPSConfig.xml
	# Destination Server

	# Copy config to destination server
	Copy-Item -path C:\dtiq\NPS\NPSConfig.xml -destination \\$NPSDestServer\C$\dtiq\NPS\NPSConfig.xml
	# Export current config
	Invoke-Command -ComputerName $NPSDestServer -ScriptBlock { Export-NPSConfiguration -Path C:\dtiq\NPS\BackupNPSConfig.xml }
	# Import new config
	Invoke-Command -ComputerName $NPSDestServer -ScriptBlock { Import-NPSConfiguration -Path C:\dtiq\NPS\NPSConfig.xml }
	
	start-sleep -Seconds $restart
	
}
until ($infinity)


Write-EventLog -log DTIQ-RemoteMan -source DTIQ -EntryType Information -eventID 1200 -Message "DTIQ NSP Config has been exported from hostname and imported into $NPSDestServer "
