function Register-ScmTarget {
    <#
    .SYNOPSIS
        Registers a Target to the Server Configuration Manager.
    
    .DESCRIPTION
        Registers a Target to the Server Configuration Manager.
        Targets are labels linked to a scriptblock.
        A computer is considered to be targeted, if the scriptblock returns $true when run as local system on the affected system.
        The scriptblock will receive no arguments and must execute selfcontained.

        Configuration entries are assigned to target labels.
    
    .PARAMETER Name
        The name of the Target.
    
    .PARAMETER ScriptBlock
        The executing code that determines, whether the current computer is part of that Target.
        Should return $true if it is.
    
    .EXAMPLE
        PS C:\> Register-ScmTarget -Name MemberServer -ScriptBlock $code

        Registers the scriptblock $code as "MemberServer"
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [Parameter(Mandatory = $true)]
        [scriptblock]
        $ScriptBlock
    )
	
    process {
        $script:targets[$Name] = [PSCustomObject]@{
            PSTypeName = 'ServerConfigurationManager.Target'
            Name = $Name
            ScriptBlock = $ScriptBlock
        }
    }
}