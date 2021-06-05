function Resolve-Target {
    <#
    .SYNOPSIS
        Resolve the targets that apply to the current computer.
    
    .DESCRIPTION
        Resolve the targets that apply to the current computer.

        Requires the current target logic to already have been imported through Import-Target.
    
    .EXAMPLE
        PS C:\> Resolve-Target

        Returns the names of targets the current computer is part of-
    #>
    [OutputType([string])]
    [CmdletBinding()]
    Param ()
	
    begin {
        $list = [System.Collections.ArrayList]@()
    }
    process {
        foreach ($targetObject in $script:targets.Values) {
            Write-ScmLog -Source ScmDebug -EventId 2000 -Message "Testing for target: $($targetObject.Name)"
            try {
                [bool]$result = & $targetObject.ScriptBlock
                Write-ScmLog -Source ScmDebug -EventId 2001 -Message "Test completed: $result"
                if ($result) {
                    $null = $list.Add($targetObject.Name)
                    $targetObject.Name
                }
            }
            catch {
                Write-ScmLog -Type Warning -EventId 2002 -Message "Error processing target: $($targetObject.Name)" -ErrorRecord $_
            }
        }
    }
    end {
        Write-ScmLog -EventId 2003 -Message "$($list.Count)# Targets met: $($list -join ", ")"
    }
}
