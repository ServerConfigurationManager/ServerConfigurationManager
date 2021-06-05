@{

    # Script module or binary module file associated with this manifest.
    RootModule        = 'ServerConfigurationManager.psm1'

    # Version number of this module.
    ModuleVersion     = '1.0.0'

    # ID used to uniquely identify this module
    GUID              = '7a54c764-8e5b-4355-ba6d-34e82cf024bb'

    # Author of this module
    Author            = 'Friedrich Weinmann'

    # Company or vendor of this module
    CompanyName       = 'Microsoft'

    # Copyright statement for this module
    Copyright         = '(c) Friedrich Weinmann. All rights reserved.'

    # Description of the functionality provided by this module
    Description       = 'Lightweight Computer Configuration Management System'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
		'Invoke-ServerConfiguration'
		'Register-ScmAction'
		'Register-ScmTarget'
		'Write-ScmLog'
    )

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData       = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('Configuration')

            # A URL to the license for this module.
            # LicenseUri = ''

            # A URL to the main website for this project.
            # ProjectUri = ''

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            # ReleaseNotes = ''
        } # End of PSData hashtable

    } # End of PrivateData hashtable
}