# Per-repo fleet start config for autohotkey-test
# RETIRED 2026-10-03: stale clone of autohotkey-tools, same bridge on 10764.
# Marked non-live (Kind none, ports 0) so fleet.lock.json ignores it.
# To revive: run claim_ports.py --repo autohotkey-test --apply for a fresh pair.
@{
    Name         = 'autohotkey-test'
    BackendPort  = 0
    FrontendPort = 0
    HealthPath   = '/status'
    WebRoot      = 'D:\Dev\repos\autohotkey-test'
    Backend = @{
        Kind    = 'none'
    }
    Frontend = @{
        Kind = 'none'
    }
}

