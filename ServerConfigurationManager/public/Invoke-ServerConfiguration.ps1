function Invoke-ServerConfiguration {
    <#
    .SYNOPSIS
        Execute all applicable configuration entries against the local computer.
    
    .DESCRIPTION
        Execute all applicable configuration entries against the local computer.
        This is the primary Server Configuration Manager command that performs the full deployment / application against the local computer.
    
    .PARAMETER RepositoryName
        The name of the PowerShell repository used as part of this workflow.
    
    .PARAMETER ContentPath
        The path to where all the Actions, Targets and Configurations are stored.
    
    .PARAMETER PassThru
        Whether the application result should be passed through to the console, rather than a simple error if it fails and nothing otherwise.
    
    .EXAMPLE
        PS C:\> Invoke-ServerConfiguration -RepositoryName $RepositoryName -ContentPath $ContentPath

        Execute all applicable configuration entries against the local computer.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]
        $RepositoryName,
    
        [Parameter(Mandatory = $true)]
        [string]
        $ContentPath,

        [switch]
        $PassThru
    )
	
    begin {
        Assert-Repository -Name $RepositoryName -Cmdlet $PSCmdlet
        Assert-ContentPath -Path $ContentPath -Cmdlet $PSCmdlet
    }
    process {
        Import-Target -ContentPath $ContentPath
        Import-Action -ContentPath $ContentPath
        $targets = Resolve-Target
        $configuration = Import-Configuration -ContentPath $ContentPath -Targets $targets | Sort-Object Tier, Weight

        $deploymentState = @{ }
        $executionResult = foreach ($configurationItem in $configuration) {
            Invoke-Configuration -Config $configurationItem -RepositoryName $RepositoryName -ContentPath $ContentPath -DeploymentState $deploymentState
        }

        if ($PassThru) { return $executionResult }
        if ($failed = $executionResult | Where-Object Status -NE 'Success') {
            Write-ScmLog -EventId 666 -Type Error -Message "Invocation failed for $(($failed | Measure-Object).Count) items"
            throw "Invokation failed for $(($failed | Measure-Object).Count) items"
        }
    }
}
