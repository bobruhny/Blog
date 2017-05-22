<#
.DESCRIPTION
With this function it is very easy to write eventlogs, even if the log or source not exists. The source or eventlog will create on fly. It dosn't metter if this happend local or an a remote machine. You need full permission to the eventlog.	
.SYNOPSIS
This function proviedes the posebility to write Eventlogs or Filelogs.
.EXAMPLE
Write Eventlog with default values (Information, PowerShell Source and Windows PowerShell Logname)
PS New-Log.ps1 -Logentry "Logentry"
.EXAMPLE
Write Eventlg with default values an a Logfile to C:\Logs\
PS New-Log.ps1 -Logentry "Logentry" -Path C:\Logs
.EXAMPLE
Write Eventlog with ErrorCode 13 (Error) on Remote Machine "SERVER01" in Eventlog "Exchange" with Source "My Function"
PS New-Log.ps1 -ErrorCode ErrorCode13 -Logentry "New Entry" -ComputerName SERVER01 -Source 'My Function' -LogName 'Exchange'
.EXAMPLE
Write No Eventlog just in a Logfile at C:\Logs\
PS New-Log.ps1 -NoEventlogentry -Logentry "New Entry"
.NOTES
Date: 22.05.2017
Version: 1.0.0.0
Author: Andreas Bittner
Mail: andy@joinpowershell.de
.LINK
http://joinpowershell.de

Write-Eventlog
New-EventLog
#>
[CmdletBinding(SupportsShouldProcess = $true)]
	param
	(
		[Parameter(Position = 1)]
		[ValidateSet('ErrorCode1', 'ErrorCode6', 'ErrorCode13')]
		[String]$ErrorCode = 'ErrorCode1',
		[Parameter(Mandatory = $true,
				   Position = 0)]
		[String]$Logentry,
		[switch]$NoEventlogentry,
		[Parameter(Mandatory = $false,
				   Position = 2)]
		[String]$Source = "PowerShell",
		[Parameter(Mandatory = $false)]
		[String]$LogName = "Windows PowerShell",
		[Parameter(Mandatory = $false)]
		[string]$ComputerName = $env:COMPUTERNAME,
		[Parameter(Mandatory = $false)]
		[string]$Path
			
) #end param

	
	if (!$NoEventlogentry)
	{
		Write-Verbose "Create EventlogEntry"
		$Date = Get-Date -Format yyyy_MM_dd
		Write-Verbose "Date is $Date"
		Write-Verbose "Tetst if EventLog  $LogName on $ComputerName exists"
		$LogExists = [System.Diagnostics.EventLog]::Exists($LogName, $ComputerName)
		Write-Verbose "Tetst if source $Source on $ComputerName exists"
		$SourceExists = [System.Diagnostics.EventLog]::SourceExists($Source, $ComputerName)
		Write-Verbose "Log Exists is $LogExists"
		Write-Verbose "Source Exists is $SourceExists"
	
	if (!$LogExists)
	{
		
		if ($PSCmdlet.ShouldProcess("$LogName", 'Create Log'))
		{
			
		$newlog=[System.Diagnostics.EventLog]::new()
		}
		
	}# end logexists
	
		if (!$SourceExists)
		{
			if ($PSCmdlet.ShouldProcess("$ComputerName", 'Create EventSource'))
			{
				Write-Verbose "Create Source"
			[System.Diagnostics.EventLog]::CreateEventSource($Source, $LogName, $ComputerName)
			Write-Verbose "Source Created"
			}
		} # end if SourceExists
		
	
		Write-Verbose "ErrorCode is $ErrorCode"
		switch ($ErrorCode)
		{
			'ErrorCode1' {
				$Type = 'Information'
				$Exeption = 'Information'
				$Id = 100
			}
			'ErrorCode6' {
				$Type = 'Warning'
				$Exeption = 'Warning'
				$Id = 600
			}
			'ErrorCode13' {
				$Type = 'Error'
				$Exeption = 'Error'
				$Id = 1300
			}
			default
			{
				$Type = 'Information'
				$Id = 100
			}
			
		}#end switch errorcode
		Write-Verbose "Errortype is $Type"
		Write-Verbose "Errorexeption is $Exeption"
		Write-Verbose "ErrorID is $Id"
		
		$Time = Get-Date -Format 'HH:mm:ss'
		Write-Verbose "Time is $Time"
		$Logentry = "$Exeption : $Logentry"
		If ($PSCmdlet.ShouldProcess("$ComputerName", 'Write-Eventlog'))
		{
			Write-Verbose "Write Eventlog"
		
		Write-EventLog -Source $Source -EntryType $type -Message $Logentry -ID $Id -LogName $LogName -ComputerName $ComputerName
		Write-Verbose "Eventlog written"
		}
	} #end if noeventlogentry
	
	If ($PSBoundParameters.ContainsKey('Path'))
	{
		Write-Verbose "Create LogFile"
		$date = Get-Date -Format yyyyMMdd
		Write-Verbose "Date is $Date"
		$time = Get-Date -Format hh:mm:ss:
		Write-Verbose "Time is $Time"
		Write-Verbose "Create Logpath"
		$logfolder = "$Source"
		$logfile = "$date" + ".log"
		$logpath = "$Path" + "$logfolder" + "\$logfile"
		Write-Verbose "Logpath is $logpath"
		Write-Verbose "Check Logpath"
		If (!(Test-Path $logpath) -eq $true){
			
			If ($PSCmdlet.ShouldProcess("$ComputerName", 'New-Item'))
			{
				
					Write-Verbose "Create Logpath"
					New-Item -Path $logpath -ItemType File -Force -Credential $Credential
					
					Write-Verbose "LogPath Created"
			}
		} # end if $logpath -eq false
		
		$PSCmdlet.ShouldProcess("$logpath", "Add-Content")
		Add-Content -Path $logpath -Value "`r`n$time`t`a$Logentry" -Credential $Credential
	
} #End contains path
