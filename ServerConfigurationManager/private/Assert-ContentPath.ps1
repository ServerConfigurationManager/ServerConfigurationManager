function Assert-ContentPath {
    <#
    .SYNOPSIS
        Ensures the specified content path is legitimate.
    
    .DESCRIPTION
        Ensures the specified content path is legitimate.

        A content path is legitimate when ...
        - It exists & is a folder
        - Has a child folder named "actions"
        - Has a child folder named "configuration"
        - Has a child folder named "targets"
    
    .PARAMETER Path
        The Content Path being validated.
    
    .PARAMETER Cmdlet
        The $PSCmdlet variable of the calling command.
    
    .EXAMPLE
        PS C:\> Assert-ContentPath -Path $ContentPath -Cmdlet $PSCmdlet

        Throws a terminating exception if the specified path does not exist or lacks the required subfolder structure.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]
        $Path,
        
        [Parameter(Mandatory = $true)]
        $Cmdlet
    )
	
    process {
        $rootExists = Test-Path -Path $Path -PathType Container
        $actionsExists = Test-Path -Path "$Path/actions" -PathType Container
        $targetsExists = Test-Path -Path "$Path/targets" -PathType Container
        $configurationExists = Test-Path -Path "$Path/configuration" -PathType Container

        if ($rootExists -and $actionsExists -and $targetsExists -and $configurationExists) {
            return
        }

        $message = "Invalid configuration source from root '$Path': Root $rootExists | Actions $actionsExists | Targets $targetsExists | Config $configurationExists"
        Write-ScmLog -Message $message -EventId 404 -Type Error

        $exception = [System.ArgumentException]::new($message)
        $errorRecord = [System.Management.Automation.ErrorRecord]::new($exception, 'InvalidContentPath', 'InvalidArgument', $null)
        $Cmdlet.ThrowTerminatingError($errorRecord)
    }
}