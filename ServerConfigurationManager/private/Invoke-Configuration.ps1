function Invoke-Configuration {
    <#
    .SYNOPSIS
        Executes a configuration against the current computer.
    
    .DESCRIPTION
        Executes a configuration against the current computer.
    
    .PARAMETER Config
        The configuration object to execute.
    
    .PARAMETER RepositoryName
        The name of the PSRepository used by the Server Configuration Manager system.
        Used in Actions that need to access packages for their workflow.
    
    .PARAMETER ContentPath
        Path to the base content directory.
        Used in Actions that need additional resources.
    
    .PARAMETER DeploymentState
        Hashtable tracking the deployment state of all configuration entries as part of a full configuration invocation.
        This hashtable is used for determining whether dependencies on other Configuration entries have been met.
    
    .EXAMPLE
        PS C:\> Invoke-Configuration -Config $configurationItem -RepositoryName $RepositoryName -ContentPath $ContentPath -DeploymentState $deploymentState

        Executes the configuration item $configurationItem with the specified runtime metadata.
    #>
    [CmdletBinding()]
    Param (
        $Config,
        
        [string]
        $RepositoryName,
        
        [string]
        $ContentPath,
        
        [hashtable]
        $DeploymentState
    )
	
    begin {
        #region Utility Function
        function Write-Result {
            [CmdletBinding()]
            param (
                $Config,
                $DeploymentState,
                $Status,
                $Data
            )

            $DeploymentState[$Config.Name] = $Status
            [PSCustomObject]@{
                PSTypeName    = 'ServerConfigurationManager.Result'
                Name          = $Config.Name
                Configuration = $Config
                Status        = $Status
                Data          = $Data
            }
        }
        #endregion Utility Function
    }
    process {
        #region Format Validation
        if (-not $Config.Name) {
            Write-ScmLog -EventId 5000 -Type Error -Message "Invalid Configuration Entry - [Name] is missing: $Config"
            return
        }
        if (-not $Config.Action) {
            Write-ScmLog -EventId 5001 -Type Error -Message "Invalid Configuration Entry - [Action] is missing: $Config"
            return
        }
        #endregion Format Validation

        #region Parameter Validation
        Write-ScmLog -EventId 5002 -Message "Processing Configuration $($Config.Name) ($($Config.Action)) | $($Config.Target)"
        $resultDefaults = @{
            Config          = $Config
            DeploymentState = $DeploymentState
        }
        
        Write-ScmLog -Source ScmDebug -Message "[$($Config.Name)] Processing Parameters"
        $parameters = @{ }
        if ($Config.Parameters) {
            if ($Config.Parameters -is [Hashtable]) {
                $parameters += $Config.Parameters
            }
            else {
                foreach ($property in $Config.Parameters.PSObject.Properties) {
                    $parameters[$property.Name] = $property.Value
                }
            }
        }
        $scriptParameters = @{
            Parameters        = $parameters
            Repository        = $RepositoryName
            ContentPath       = $ContentPath
            ConfigurationName = $Config.Name
        }
        Write-ScmLog -Source ScmDebug -Message "[$($Config.Name)] #$($parameters.Count) Parameters found: $($parameters.Keys -join ",")"

        $actionObject = $script:actions[$Config.Action]
        if (-not $actionObject) {
            Write-ScmLog -EventId 5003 -Type Error -Message "[$($Config.Name)] Unknown Action: $($Config.Action)"
            Write-Result @resultDefaults -Status 'Unknown Action' -Data $Config.Action
            return
        }
        $missingParameters = foreach ($parameterName in $actionObject.ParametersRequired.Keys) {
            if ($parameters.Keys -contains $parameterName) { continue }
            Write-ScmLog -EventId 5004 -Type Error -Message "[$($Config.Name)] Missing required parameter: $($parameterName)"
            $parameterName
        }
        if ($missingParameters) {
            Write-Result @resultDefaults -Status 'Bad Parameters' -Data $missingParameters
            return
        }
        Write-ScmLog -Source ScmDebug -Message "[$($Config.Name)] All required parameters found"
        #endregion Parameter Validation

        #region Dependency Validation
        Write-ScmLog -Source ScmDebug -Message "[$($Config.Name)] Processing Parameters"
        if ($Config.DependsOn) {
            $missingDependencies = foreach ($dependency in $Config.DependsOn) {
                if ($DeploymentState[$dependency] -eq 'Success') { continue }
                Write-ScmLog -EventId 5005 -Type Error -Message "[$($Config.Name)] Dependency not met: $($dependency)"
                $dependency
            }

            if ($missingDependencies) {
                Write-Result @resultDefaults -Status 'Dependency not met' -Data $missingDependencies
                return
            }
        }
        Write-ScmLog -Source ScmDebug -Message "[$($Config.Name)] Processing Parameters - Completed"
        #endregion Dependency Validation

        #region Pre-Test
        Write-ScmLog -Source ScmDebug -Message "[$($Config.Name)] Executing Pre-Test"
        try { $testResult = & $actionObject.Validation $scriptParameters }
        catch {
            Write-ScmLog -EventId 5006 -Type Error -Message "[$($Config.Name)] Error executing test" -ErrorRecord $_
            Write-Result @resultDefaults -Status 'Error executing test' -Data $_
            return
        }
        if ($testResult) {
            Write-ScmLog -EventId 5007 -Message "[$($Config.Name)] Test successful, configuration already applied"
            Write-Result @resultDefaults -Status 'Success'
            return
        }
        Write-ScmLog -Source ScmDebug -Message "[$($Config.Name)] Executing Pre-Test - Completed"
        #endregion Pre-Test

        #region Execution
        Write-ScmLog -Source ScmDebug -Message "[$($Config.Name)] Executing Configuration"
        try { $null = & $actionObject.Execution $scriptParameters }
        catch {
            Write-ScmLog -EventId 5008 -Type Error -Message "[$($Config.Name)] Error executing Action $($Config.Action)" -ErrorRecord $_
            Write-Result @resultDefaults -Status 'Error executing configuration' -Data $_
            return
        }
        Write-ScmLog -Source ScmDebug -Message "[$($Config.Name)] Executing Configuration - Completed"
        #endregion Execution

        #region Post-Test
        Write-ScmLog -Source ScmDebug -Message "[$($Config.Name)] Executing Post-Test"
        try { $testResult = & $actionObject.Validation $scriptParameters }
        catch {
            Write-ScmLog -EventId 5009 -Type Error -Message "[$($Config.Name)] Error executing test" -ErrorRecord $_
            Write-Result @resultDefaults -Status 'Error executing test' -Data $_
            return
        }
        if ($testResult) {
            Write-ScmLog -EventId 5010 -Message "[$($Config.Name)] Test successful, configuration successfully applied"
            Write-Result @resultDefaults -Status 'Success'
            return
        }
        else {
            Write-ScmLog -EventId 5011 -Type Error -Message "[$($Config.Name)] Test failed, execution not successful"
            Write-Result @resultDefaults -Status 'Failed'
            return
        }
        #endregion Post-Test
    }
}