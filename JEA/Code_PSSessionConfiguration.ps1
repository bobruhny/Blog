##############Registrierte Endpunkte anzeigen##############
Get-PSSessionConfiguration

##############Erstellen der PSSEssionConfiguration#########

New-Item-Path $env:ProgramData\JEA -ItemType Directory

$pssessionconfig = @{
	
	Path = "$env:ProgramData\JEA\JEAAccessDNS.pssc"
	RunAsVirtualAccount = $true
	SessionType = "RestrictedRemoteServer"
	RoleDefinitions = @{ 'joinpowershell\sorglossu' = @{ RoleCapabilities = 'RolecapabilityDNS' } }
	
}

New-PSSessionConfigurationFile @pssessionconfig


##############Anpassen der Datei###########################

$psroleconfig
= @{
	Path = "$PathRC\JEAAccessDNS\RoleCapabilities\RolecapabilityDNS.psrc"
	Company = "JoinPowerShell"
	Description = "Configuration for Networkoperators"
	ModulesToImport = "DNSServer"
	VisibleCmdlets = 'Get-Service', @{ Name = 'Restart-service'; Parameters = @{ Name = 'Name'; ValidateSet = 'DNS' } }, 'NetTCPIP\Get-*'
	VisibleFunctions = '*-DNSServerResourceRecord*'
	VisibleExternalCommands = 'C:\Windows\System32\ipconfig.exe'
	FunctionDefinitions = @{ Name = 'Get-UserInfo'; ScriptBlock = { $PSSenderInfo } }
	
}

