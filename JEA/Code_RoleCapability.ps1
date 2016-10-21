#######################PreConf########################

######Modulpfad
$PathRC = "$env:ProgramFiles\WindowsPowerShell\Modules\"
#####Erstellen der Ordnerstruktur und PSRC Datei
New-Item -Path "$PathRC\JEAAccessDNS\RoleCapabilities" -ItemType Directory
####Erstellen der Manifestdatei welche für jedes Modul notwendig ist
New-ModuleManifest -Path "C:\Program Files\WindowsPowerShell\Modules\JEAAccessDNS\DNSOperators.psd1"
New-PSRoleCapabilityFile -Path "$PathRC\JEAAccessDNS\RoleCapabilities\RolecapabilityDNS.psrc"


#########################Create File####################
$psroleconfig= @{

Path ="$PathRC\JEAAccessDNS\RoleCapabilities\RolecapabilityDNS.psrc"
Company ="JoinPowerShell"
Description ="Configuration for Networkoperators"
VisibleCmdlets ='Add-DnsServerResourceRecordA', 'Remove-DnsServerResourceRecord'
FunctionDefinitions = @{ Name = 'Get-UserInfo'; ScriptBlock = { $PSSenderInfo } }
}

New-PSRoleCapabilityFile @psroleconfig


