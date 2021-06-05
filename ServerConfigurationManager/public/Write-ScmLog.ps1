function Write-ScmLog {
    <#
    .SYNOPSIS
        Write a log message.
    
    .DESCRIPTION
        Write a log message.
    
    .PARAMETER Message
        The message to write.
    
    .PARAMETER Type
        What kind of message to write.
        Defaults to Information
    
    .PARAMETER EventId
        The id of the event to generate.
        Defaults to 1000
    
    .PARAMETER Source
        The source of the eventlog message.
        Defaults to 'ScmExecution'

    .PARAMETER ErrorRecord
        The error record to log.
    
    .EXAMPLE
        PS C:\> Write-ScmLog -Message "Starting action import"

        Generates the informational log entry stating that the action import is starting.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Message,

        [System.Diagnostics.EventLogEntryType]
        $Type = 'Information',

        [int]
        $EventId = 1000,

        [ValidateSet('ScmLauncher', 'ScmExecution', 'ScmDebug', 'ScmAction')]
        [string]
        $Source = 'ScmExecution',

        [System.Management.Automation.ErrorRecord]
        $ErrorRecord
    )

    if ($ErrorRecord) {
        $Message += " | $ErrorRecord"
    }

    If ($Type -eq 'Error') { Write-Warning $Message }
    else { Write-Verbose $Message }
    try {
        $eventlog = [System.Diagnostics.EventLog]::GetEventLogs().Where{ $_.Log -eq "ServerConfigurationManager" }[0]
        $eventlog.Source = $Source
        $eventlog.WriteEntry($Message, $Type, $EventId)
    }
    catch {
        # Do nothing if it fails
    }

    if ($ErrorRecord) {
        $debugString = @'
Error:
Message: {0}

ScriptStackTrace:
{1}

Target: {2}
ErrorId: {3}
Category: {4}

Position:
{5}

Exception:
{6}
'@ -f $ErrorRecord, $ErrorRecord.ScriptStackTrace, $ErrorRecord.TargetObject, $ErrorRecord.FullyQualifiedErrorId, $ErrorRecord.CategoryInfo, $ErrorRecord.InvocationInfo.PositionMessage, ($ErrorRecord.Exception | Format-List -Force | Out-String)
        Write-ScmLog -Source ScmDebug -Message $debugString -EventId 1 -Type Warning
    }
}