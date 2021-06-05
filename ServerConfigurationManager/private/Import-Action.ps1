function Import-Action {
    <#
    .SYNOPSIS
        Imports all configured action files.
    
    .DESCRIPTION
        Imports all configured action files.
    
    .PARAMETER ContentPath
        The path to the SCM content.
    
    .EXAMPLE
        PS C:\> Import-Action -ContentPath $ContentPath

        Imports all action files under the path specified in $ContentPath.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]
        $ContentPath
    )
	
    process {
        $actionPath = Join-Path -Path $ContentPath -ChildPath 'actions'
        foreach ($file in Get-ChildItem -Path $actionPath -File -Recurse | Where-Object Extension -eq '.ps1') {
            Write-ScmLog -Message "Loading Action: $($file.BaseName) ($($file.FullName))"
            try {
                # Loading the file straight with & would shift the script scope to the file we are importing, breaking any internal calls the script performs.
                # Dotsourcing the file straight would give it direct access the function variables, adding conflict potential.
                # This way it executes in a child scope but does not shift the script scope outside of the module
                $null = & {
                    param ($File)
                    . $File.FullName
                } $file
                Write-ScmLog -Message "Loading Action: $($file.BaseName) Successful"
            }
            catch {
                Write-ScmLog -Message "Loading Action: $($file.BaseName) Failed" -Type Error -EventId 500 -ErrorRecord $_
            }
        }
    }
}