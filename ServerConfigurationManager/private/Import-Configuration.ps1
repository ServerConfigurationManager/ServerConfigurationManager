function Import-Configuration {
    <#
    .SYNOPSIS
        Import configuration PSD1 files from the configuration path.
    
    .DESCRIPTION
        Import configuration PSD1 files from the configuration path.

        For each applicable target it will look for a folder of the same name in the configuration folder.
        For each folder thus found it will search for config psd1 files inside of that folder and load them.

        See documentation for legal config file structure.
    
    .PARAMETER ContentPath
        The root path to where SCM content is stored.
        It will look in the configuration subfolder for relevant settings.
    
    .PARAMETER Targets
        The Targets that are applicable and should have configuration loaded for.
    
    .EXAMPLE
        PS C:\> Import-Configuration -ContentPath $ContentPath -Targets $targets

        Load all configuration settings for the determined targets from $ContentPath
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]
        $ContentPath,

        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [string[]]
        $Targets
    )
	
    process {
        $configPath = Join-Path -Path $ContentPath -ChildPath 'configuration'
        foreach ($targetName in $Targets) {
            Write-ScmLog -Source ScmDebug -Message "Importing config for $targetName" -EventId 2200
            $targetPath = Join-Path -Path $configPath -ChildPath $targetName
            if (-not (Test-Path -Path $targetPath)) {
                Write-ScmLog -Source ScmDebug -Message "No config folder detected" -EventId 2201
                continue
            }

            foreach ($configFile in Get-ChildItem -Path $targetPath -Recurse -File | Where-Object Extension -EQ '.psd1') {
                Write-ScmLog -Source ScmDebug -Message "Loading Config File: $($configFile.FullName)" -EventId 2202
                try { Import-PowerShellDataFile -Path $configFile.FullName -ErrorAction Stop }
                catch {
                    Write-ScmLog -Type Warning -Message "Error loading Config File $($configFile.FullName)" -EventId 2203 -ErrorRecord $_
                }
            }
        }
    }
}
