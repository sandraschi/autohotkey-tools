# Per-repo fleet start config for autohotkey-tools
# Edit ports/backend target here - start.ps1 is fleet-standard.
@{
    Name         = 'autohotkey-tools'
    BackendPort  = 10764
    FrontendPort = 0
    HealthPath   = '/status'
    WebRoot      = $PSScriptRoot
    Backend = @{
        Kind    = 'custom'
        WorkDir = $PSScriptRoot
        Command = "& '$PSScriptRoot\scripts\Start-ScriptletBridge.ps1'"
    }
    Frontend = @{
        Kind = 'none'
    }
}
