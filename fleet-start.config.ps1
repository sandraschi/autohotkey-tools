# Per-repo fleet start config for autohotkey-test
# Edit ports/backend target here - start.ps1 is fleet-standard.
@{
    Name         = 'autohotkey-test'
    BackendPort  = 10744
    FrontendPort = 0
    HealthPath   = '/status'
    WebRoot      = 'D:\Dev\repos\autohotkey-test'
    Backend = @{
        Kind    = 'custom'
        WorkDir = 'D:\Dev\repos\autohotkey-test'
        Command = "& 'D:\Dev\repos\autohotkey-test\scripts\Start-ScriptletBridge.ps1'"
    }
    Frontend = @{
        Kind = 'none'
    }
}
