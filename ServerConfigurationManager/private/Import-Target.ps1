function Import-Target {
    <#
    .SYNOPSIS
        Imports all configured target files.
    
    .DESCRIPTION
        Imports all configured target files.
    
    .PARAMETER ContentPath
        The path to the SCM content.
    
    .EXAMPLE
        PS C:\> Import-Target -ContentPath $ContentPath

        Imports all target files under the path specified in $ContentPath.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]
        $ContentPath
    )
	
    process {
        $targetPath = Join-Path -Path $ContentPath -ChildPath 'targets'
        foreach ($file in Get-ChildItem -Path $targetPath -File -Recurse | Where-Object Extension -eq '.ps1') {
            Write-ScmLog -Message "Loading Target: $($file.BaseName) ($($file.FullName))"
            try { 
                # Loading the file straight with & would shift the script scope to the file we are importing, breaking any internal calls the script performs.
                # Dotsourcing the file straight would give it direct access the function variables, adding conflict potential.
                # This way it executes in a child scope but does not shift the script scope outside of the module
                $null = & {
                    param ($File)
                    . $File.FullName
                } $file
                Write-ScmLog -Message "Loading Target: $($file.BaseName) Successful"
            }
            catch {
                Write-ScmLog -Message "Loading Target: $($file.BaseName) Failed" -Type Error -EventId 501 -ErrorRecord $_
            }
        }
    }
}