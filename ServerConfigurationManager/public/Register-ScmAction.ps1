function Register-ScmAction {
    <#
    .SYNOPSIS
        Register an Action to the Server Configuration Manager.
    
    .DESCRIPTION
        Register an Action to the Server Configuration Manager.
        Actions are the implementing logic, that turns configuration into reality.

        A configuration entry might require for a PowerShell module to exist on the computer.
        The action is that makes it happen.

        Both scriptblocks implementing this receive a single hashtable as argument.
        The hashtable comes with the following keys:
        - Parameters:        A Custom Object containing the parameters specified in the configuration entry.
        - Repository:        The name of the PowerShell repository used for the SCM.
        - ContentPath:       The root path to where the SCM content (such as configuration data) is at.
        - ConfigurationName: Name of the configuration setting (mostly for logging purposes)
    
    .PARAMETER Name
        The name of the Action.
    
    .PARAMETER Description
        A description of the Action, documenting what it is all about and how to use it.
    
    .PARAMETER ParametersRequired
        A list of parameters that must be specified, in order for this action to be viable.
        The name of the parameter would be the key, a description of the parameter the value.
    
    .PARAMETER ParametersOptional
        A list of parameters that may optionally be specified.
        The name of the parameter would be the key, a description of the parameter the value.
    
    .PARAMETER Validation
        Scriptblock validating, whether the desired state already exists.
    
    .PARAMETER Execution
        Scriptblock bringing the current computer into the desired state.
    
    .EXAMPLE
        PS C:\> Register-ScmAction @parameters

        Registers a new SCM Action.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [Parameter(Mandatory = $true)]
        [string]
        $Description,

        [Parameter(Mandatory = $true)]
        [hashtable]
        $ParametersRequired,

        [Parameter(Mandatory = $true)]
        [hashtable]
        $ParametersOptional,

        [Parameter(Mandatory = $true)]
        [scriptblock]
        $Validation,

        [Parameter(Mandatory = $true)]
        [scriptblock]
        $Execution
    )
	
    process {
        $script:actions[$Name] = [pscustomobject]@{
            PSTypeName         = 'ServerConfigurationManager'
            Name               = $Name
            Description        = $Description
            ParametersRequired = $ParametersRequired
            ParametersOptional = $ParametersOptional
            Validation         = $Validation
            Execution          = $Execution
        }
    }
}