$sources = @(
    'ScmLauncher'
    'ScmExecution'
    'ScmDebug'
    'ScmAction'
)

foreach ($source in $sources) {
    try {
        if (-not [System.Diagnostics.EventLog]::SourceExists($source)) {
            [System.Diagnostics.EventLog]::CreateEventSource($source, "ServerConfigurationManager")
        }
    }
    catch { }
}