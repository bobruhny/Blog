<#	
.EXAMPLE
Compare-GroupMembership -RefferenceGroup 'DD_Hotline' -DifferenceGroup 'DD_Hardware'



SameaccountName GroupMember Type           
--------------- ----------- ----           
Bart            DD_Hotline  RefferenceGroup
Marge           DD_Hotline  RefferenceGroup
Willie          DD_Hardware DifferenceGroup
Ralph           DD_Hardware DifferenceGroup




        Menu
--------------------------
1. compare (Reff <- Diff)
2. Switch
3. Exit

Select a menu choice: 2
Refferencegroup Member:

name         
----         
Bart Simpson 
Marge Simpson



Differencegroup Member:

name  
----  
Willie
Ralph 

.EXAMPLE
Compare-GroupMembership -RefferenceGroup 'DD_Hotline' -DifferenceGroup 'DD_Hardware'



SameaccountName GroupMember Type           
--------------- ----------- ----           
Willie          DD_Hotline  RefferenceGroup
Ralph           DD_Hotline  RefferenceGroup
Bart            DD_Hardware DifferenceGroup
Marge           DD_Hardware DifferenceGroup




        Menu
--------------------------
1. compare (Reff <- Diff)
2. Switch
3. Exit

Select a menu choice: 1
GroupMembers:

name         
----         
Willie       
Ralph        
Bart Simpson 
Marge Simpson

#>

function Compare-GroupMembership
{
	[CmdletBinding(ConfirmImpact = 'Medium',
				   PositionalBinding = $true,
				   SupportsShouldProcess = $true)]
	param
	(
		[Parameter(Mandatory = $true)]
		[String]$RefferenceGroup,
		[Parameter(Mandatory = $true)]
		[String]$DifferenceGroup
	)
	
	BEGIN
	{
		
		try
		{
			$ReffGroup = Get-ADGroup -Identity $RefferenceGroup -ea Stop
			
			$DiffGroup = Get-ADGroup -Identity $DifferenceGroup -ea Stop
			
			
			
		}
		catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
		{
			Write-Error "One AD group not exist!"
			
		} #End try/catch
		
		
		
		#Check Groups
		
		
	} #End BEGIN 
	
	PROCESS
	{
		
		Write-Verbose "Get refferencegroupmembership"
		$refferencemembership = Get-ADGroupMember -Identity $ReffGroup.SamAccountName
		Write-Verbose "Get differencegroupmembership"
		$differencemembership = Get-ADGroupMember -Identity $DiffGroup.SamAccountName
		Write-Verbose "compare Groups"
		$compared = Compare-Object -ReferenceObject $refferencemembership -DifferenceObject $differencemembership -Property SamAccountName
		
		
		
		$outputall = foreach ($compare in $compared)
		{
			
			$sideindictor = $compare.SideIndicator
			
			switch ($sideindictor)
			{
				"<="{
					
					[pscustomobject]@{
						"SameaccountName" = $compare.SamAccountName
						"GroupMember" = "$RefferenceGroup"
						"Type" = "RefferenceGroup"
						
					}
					
					
				}
				
				"=>"{
					[pscustomobject]@{
						"SameaccountName" = $compare.SamAccountName
						"GroupMember" = "$DifferenceGroup"
						"Type" = "DifferenceGroup"
						
					}
					
				}
				
				"="{
					[pscustomobject]@{
						"SameaccountName" = $compare.SamAccountName
						"GroupMember" = "MemberinBothGroups"
						"Type" = ""
						
					}
					
				}
				
				
				
				
			} #EndSwitch
			
		} #End foreach compare
		
		
		$outputall | Out-String
		
		
		$menu = @"

        Menu
--------------------------
1. compare (Reff <- Diff)
2. Switch
3. Exit

Select a menu choice
"@
		
		
		[int]$r = Read-Host $menu
		
		
		switch ($r)
		{
			'1' {
				Write-Verbose "1 is select"
				Write-Verbose "Refferencegroup is $ReffGroup"
				Write-Verbose "Differencegroup is $DiffGroup"
				foreach ($member in $differencemembership)
				{
					
					Write-Verbose "Current member is $member"
					if ($PSCmdlet.ShouldProcess("$member", "Add-ADGroupMember"))
					{
						Add-ADGroupMember -Identity $ReffGroup -Members $member -Confirm:$false
					}
					
				} #End foreach differncemembership
				Write-Host "GroupMembers:" -ForegroundColor Green
				
				Get-ADGroupMember -Identity $ReffGroup.SamAccountName | select name
			}
			'2' {
				Write-Verbose "2 is select"
				Write-Verbose "Refferencegroup is $ReffGroup"
				Write-Verbose "Differencegroup is $DiffGroup"
				
				foreach ($diffmember in $differencemembership)
				{
					Write-Verbose "Current member is $diffmember"
					Write-Verbose "Add $diffmember to $ReffGroup"
					if ($PSCmdlet.ShouldProcess("$diffmember", "Add-ADGroupMember"))
					{
						Add-ADGroupMember -Identity $ReffGroup -Members $diffmember -Confirm:$false
					}
					Write-Verbose "Remove $diffmember from $DiffGroup"
					if ($PSCmdlet.ShouldProcess("$diffmember", "Remove-ADGroupMember"))
					{
						
						Remove-ADGroupMember -Identity $DiffGroup -Members $diffmember -Confirm:$false
					}
				} #End foreach differncemembership
				
				foreach ($reffmember in $refferencemembership)
				{
					Write-Verbose "Current member is $reffmember"
					Write-Verbose "Add $reffmember to $DiffGroup"
					if ($PSCmdlet.ShouldProcess("$reffmember", "Add-ADGroupMember"))
					{
						Add-ADGroupMember -Identity $DiffGroup -Members $reffmember -Confirm:$false
					}
					Write-Verbose "Remove $reffmember from $ReffGroup"
					
					if ($PSCmdlet.ShouldProcess("$reffmember", "Remove-ADGroupMember"))
					{
						Remove-ADGroupMember -Identity $ReffGroup -Members $reffmember -Confirm:$false
					}
				} #End foreach differncemembership
				
				Write-Host "Refferencegroupmember:" -ForegroundColor Green
				Get-ADGroupMember -Identity $ReffGroup.SamAccountName | select name | Out-String
				Write-Host "Differencegroupmember:" -ForegroundColor Green
				Get-ADGroupMember -Identity $DiffGroup.SamAccountName | select name | Out-String
				
				
			}
			'3' {
				Write-Verbose "3 is select"
				Write-Host "Have a nice day" -ForegroundColor Green
			}
			default
			{
				Write-Warning  "$r is not a valid choise"
				
			}
		} #End switch $r
		
		
		
		
		
	} #End PROCESS
	
	END
	{
		
	} #End END
} #End Function


#Compare-GroupMembership -RefferenceGroup 'DD_Hotline' -DifferenceGroup 'DD_Hardware'

