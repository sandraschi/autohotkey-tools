# Scriptlet Bugbash Plan (2025-11-03)

## 1. Standards & Reference Refresh
- Review official AutoHotkey v2 documentation (syntax, CLI flags, process handling, error handling) as the authoritative source.
- Cross-check repository-specific expectations in `mcp-central-docs/STANDARDS.md` and `FASTMCP_2.12_MIGRATION.md` after the v2 refresh to align automation details with existing mandates.

## 2. Scriptlet Inventory Capture
- Enumerate all `.ahk` files under `scriptlets\`, excluding:
  - Backup artifacts (`*.bak`).
  - Legacy v1 content (`scriptlets\v1\`).
- Produce `inventory.json` with entries containing:
  - Absolute file path.
  - Inferred category (games, mcp, utilities, productivity, entertainment) when derivable from folder/name.
  - Notes flag for special cases (GUI heavy, requires dependencies, etc.).

## 3. Automation Harness Design
- Use PowerShell (preferred for repo tooling) to iterate through `inventory.json`.
- Launch each script with `AutoHotkey.exe "/ErrorStdOut" "<script-path>"`.
- Record the process ID immediately on start.
- Configure per-script timeout (default 60 seconds, adjustable via param).
- Maintain option to run subsets (category filter or explicit allow list) for targeted retests.
- **Implementation:** `utils/scriptlet_bugbash.ps1` encapsulates this logic and accepts `-GenerateInventoryOnly`, `-Throttle`, `-TimeoutSeconds`, optional warning suppression via `-WarnOptions` (e.g. `"All,Off"`), and path parameters.

## 4. Execution Control & Cleanup
- On script exit or timeout:
  - Capture exit code and elapsed time.
  - If still running past timeout, attempt graceful shutdown (send `Esc` or `F9` if documented) before issuing `Stop-Process -Id <pid> -Force`.
  - Ensure no script remains resident to avoid persistent hotkeys.
- Track termination method (natural exit, graceful stop, forced kill) in the results ledger.

## 5. Logging & Error Classification
- Redirect stdout/stderr to `logs\bugbash\<script-name>.log` per run.
- Parse captured output for:
  - Syntax/runtime errors (line number, message).
  - Missing dependencies or includes.
  - Custom log output indicating latent issues.
- Store structured results in `logs\bugbash\summary.json` with fields: script, status, duration, termination method, error summary, log path.

## 6. Popup Suppression Validation
- Dry-run harness on a known error-prone scriptlet to confirm `/ErrorStdOut` eliminates GUI popups.
- Verify termination logic cleans up processes even when dialogs would have appeared.
- Document observations in the final report.

## 7. Bulk Execution & Metrics
- Execute full manifest with throttle controls (e.g., max concurrent scripts = 3) to avoid resource contention.
- Record overall stats: pass/fail counts, timeout frequency, average runtime, most common error categories.
- Preserve raw logs for post-mortem analysis.

## 8. Reporting Deliverables
- Generate `docs/Scriptlet_Bugbash_Report_2025-11-XX.md` summarizing:
  - Methodology and tooling versions (AutoHotkey path/version, harness script commit).
  - Inventory snapshot metrics (total scripts, category distribution).
  - Result matrix with links to individual logs.
  - Observations about popup suppression and termination behavior.
- Highlight high-priority fixes (e.g., scripts that crash immediately) and dependency gaps.

## 9. Remediation Workflow
- For each failing script, create follow-up tasks (todo entries or `notes/`) referencing the relevant log and error summary.
- Establish retest process: rerun harness on affected scripts after fixes to confirm clean exit.
- Update inventory metadata when fixes introduce new dependencies or change categories.

## 10. Future Enhancements
- Optional parallelization tuning with resource monitoring (CPU/RAM) prior to forced termination.
- Tag-driven subsets (games, MCP, utilities) for targeted regression runs.
- Integration with existing lint/test scripts to run bugbash as part of CI or pre-commit checks.
- Grace period customization (e.g., configurable delay between graceful key send and forced kill).
- Automated alerts or dashboards summarizing recurring failures across runs.

## Current Implementation Snapshot (2025-11-12)
- Harness script added at `utils/scriptlet_bugbash.ps1` with automatic root detection, inventory generation, logging, and force-termination safeguards.
- Initial inventory captured at `logs/bugbash/inventory_20251112_160158.json` via `-GenerateInventoryOnly` dry run.
- Summary export scaffolding prepared (`summary_<timestamp>.json` with metadata/results) for full bugbash executions.
