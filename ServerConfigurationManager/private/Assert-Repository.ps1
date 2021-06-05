function Assert-Repository {
    <#
    .SYNOPSIS
        Asserts that the intended PSRepository used for PowerShell module access exists.
    
    .DESCRIPTION
        Asserts that the intended PSRepository used for PowerShell module access exists.
    
    .PARAMETER Name
        Name of the repository to assert.
    
    .PARAMETER Cmdlet
        The $PSCmdlet variable of the calling command.
    
    .EXAMPLE
        PS C:\> Assert-Repository -Name $RepositoryName -Cmdlet $PSCmdlet

        Asserts that the repository specified in $RepositoryName actually exists.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [Parameter(Mandatory = $true)]
        $Cmdlet
    )
	
    process {
        $repository = Get-PSRepository -Name $Name -ErrorAction Ignore
        if ($repository) {return }

        $message = "PowerShell Repository '$Name' not found!"
        Write-ScmLog -Message $message -EventId 405 -Type Error

        $exception = [System.ArgumentException]::new($message)
        $errorRecord = [System.Management.Automation.ErrorRecord]::new($exception, 'InvalidRepository', 'InvalidArgument', $Name)
        $Cmdlet.ThrowTerminatingError($errorRecord)
    }
}
