<#
.SYNOPSIS
    TEMPORARY verification script for the Phase 1 gate (feature 005,
    "Automated install verification check"). Deleted once the gate passes
    (see specs/005-automated-install-verification-check/plan.md, Batch 4).

.DESCRIPTION
    Simulates a `setup-ai.md` install run entirely with local file operations
    (no bash/curl one-liner, no real HTTPS fetch - see plan.md decision #2)
    and checks that every file declared in `catalog.yaml` for the `default`
    profile ends up byte-for-byte identical to its source under
    `ai-toolkit/default/` once "installed" into a disposable scratch folder.

    - `-Target claude`: copies every catalog-declared commands/agents file
      into `.claude/commands/` and `.claude/agents/` under the scratch
      folder, matching Claude Code's native layout (tech-spec.md, Step 4 of
      setup-ai.md). This run is BLOCKING: the script exits non-zero if any
      file is missing or does not match its source byte-for-byte.

    - `-Target codex`: additionally performs a best-effort, deterministic
      translation of every catalog-declared *commands* file into
      `.codex/skills/<name>/SKILL.md` (ADR-002 / tech-spec.md, Step 5 of
      setup-ai.md). Per setup-ai.md, Codex CLI has no subagent equivalent,
      so catalog `agents` entries are intentionally NOT installed for this
      target - they are recorded as "not applicable" in the comparison,
      not as a failure. This run is NON-BLOCKING (FR-007): the script
      always exits 0 for this target, regardless of match/mismatch results,
      because the translation is a reinterpretation, not a byte-for-byte
      copy, and is documented as best-effort.

    Every run appends a dated section (per-file table + pass/fail aggregate)
    to specs/005-automated-install-verification-check/evidence.md, which is
    the permanent record of the gate (plan.md decision #6) and is NOT
    deleted along with this script.

.PARAMETER Target
    The install target to simulate: `claude` or `codex`.

.PARAMETER Method
    The install method being exercised: `oneliner` or `copypaste`. Per
    plan.md decision #4, both methods share the exact same install routine
    here (they only differ in how a human kicks off reading setup-ai.md,
    not in what gets written) - this parameter only changes the name of the
    scratch folder used, so each (target, method) combination gets its own
    independently inspectable, independently verified run.

.PARAMETER ScratchRoot
    Root folder for disposable install runs. Defaults to
    `$env:TEMP\my-aisy-toolkit-verify`. Each run deletes and recreates its
    own `<target>-<method>` subfolder, so a prior run is never reused
    (plan.md decision #3).

.EXAMPLE
    ./scripts/verify-install-temp.ps1 -Target claude -Method oneliner

.EXAMPLE
    ./scripts/verify-install-temp.ps1 -Target codex -Method oneliner -ScratchRoot C:\scratch
#>

#Requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('claude', 'codex')]
    [string]$Target,

    [Parameter(Mandatory = $true)]
    [ValidateSet('oneliner', 'copypaste')]
    [string]$Method,

    [Parameter(Mandatory = $false)]
    [string]$ScratchRoot = (Join-Path $env:TEMP 'my-aisy-toolkit-verify')
)

$ErrorActionPreference = 'Stop'
$ProfileName = 'default'

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------

# This script lives at <repo-root>/scripts/verify-install-temp.ps1.
$RepoRoot = Split-Path -Parent $PSScriptRoot
$CatalogPath = Join-Path $RepoRoot 'catalog.yaml'
$EvidencePath = Join-Path $RepoRoot 'specs\005-automated-install-verification-check\evidence.md'

function Convert-ToRepoPath {
    <#
        Catalog paths use forward slashes (e.g. ai-toolkit/default/commands/foo.md).
        Normalize to the platform separator before Join-Path.
    #>
    param([Parameter(Mandatory = $true)][string]$RelativePath)
    return (Join-Path $RepoRoot ($RelativePath -replace '/', '\'))
}

# ---------------------------------------------------------------------------
# Minimal catalog.yaml parser
#
# Sufficient (and intentionally nothing more, per plan.md decision #1's
# "zero dependencies" spirit) for catalog.yaml's actual shape:
#
#   profiles:
#     <profile>:
#       commands:
#         - <source path>
#         - <source path>
#       agents:
#         - <source path>
#         - <source path>
#
# A flat list of plain strings under `commands:`/`agents:` for each named
# profile - no nested objects, no per-item keys. No general-purpose YAML
# library is needed or used.
# ---------------------------------------------------------------------------

function Get-CatalogEntries {
    param(
        [Parameter(Mandatory = $true)][string]$CatalogPath,
        [Parameter(Mandatory = $true)][string]$ProfileName
    )

    if (-not (Test-Path -LiteralPath $CatalogPath)) {
        throw "catalog.yaml not found at '$CatalogPath'. This is a hard prerequisite (see plan.md scope note: Batches 2-5 need catalog.yaml/002 to exist) - nothing to verify."
    }

    $lines = Get-Content -LiteralPath $CatalogPath

    $commands = New-Object System.Collections.Generic.List[string]
    $agents = New-Object System.Collections.Generic.List[string]

    $inProfiles = $false
    $inTargetProfile = $false
    $currentListKey = $null

    foreach ($rawLine in $lines) {
        if ($rawLine.Trim().Length -eq 0 -or $rawLine.Trim().StartsWith('#')) {
            continue
        }

        $indent = $rawLine.Length - $rawLine.TrimStart(' ').Length
        $trimmed = $rawLine.Trim()

        if ($indent -eq 0) {
            if ($trimmed -eq 'profiles:') {
                $inProfiles = $true
            } else {
                $inProfiles = $false
            }
            $inTargetProfile = $false
            $currentListKey = $null
            continue
        }

        if (-not $inProfiles) {
            continue
        }

        # Profile name line, e.g. "  default:"
        if ($indent -eq 2 -and $trimmed -match '^([A-Za-z0-9_-]+):\s*$') {
            $inTargetProfile = ($Matches[1] -eq $ProfileName)
            $currentListKey = $null
            continue
        }

        if (-not $inTargetProfile) {
            continue
        }

        # List key line, e.g. "    commands:" or "    agents:"
        if ($indent -eq 4 -and $trimmed -match '^(commands|agents):\s*$') {
            $currentListKey = $Matches[1]
            continue
        }

        # List item line, e.g. "      - ai-toolkit/default/commands/foo.md"
        if ($indent -ge 4 -and $trimmed -match '^-\s*(.+)$' -and $currentListKey) {
            $value = $Matches[1].Trim()
            $value = $value.Trim("'").Trim('"')
            if ($currentListKey -eq 'commands') {
                [void]$commands.Add($value)
            } elseif ($currentListKey -eq 'agents') {
                [void]$agents.Add($value)
            }
            continue
        }
    }

    return [pscustomobject]@{
        Commands = $commands
        Agents   = $agents
    }
}

# ---------------------------------------------------------------------------
# Best-effort Codex SKILL.md translation (ADR-002 shape: folder-per-skill,
# `.codex/skills/<name>/SKILL.md`, YAML frontmatter). This is a deterministic
# stand-in for what an AI agent would do at install time per setup-ai.md
# Step 5 - it is explicitly NOT expected to be byte-for-byte identical to
# the Claude Code source (that is the whole point of a "translation" versus
# Step 4's verbatim copy), so a MISMATCH result here is an expected,
# documented, non-blocking outcome (plan.md decision #5, FR-007).
# ---------------------------------------------------------------------------

function ConvertTo-CodexSkill {
    param(
        [Parameter(Mandatory = $true)][string]$SourcePath,
        [Parameter(Mandatory = $true)][string]$DestinationPath,
        [Parameter(Mandatory = $true)][string]$Name
    )

    $content = Get-Content -LiteralPath $SourcePath -Raw

    $description = $null
    $body = $content

    $frontmatterPattern = '(?s)^---\r?\n(.*?)\r?\n---\r?\n?(.*)$'
    if ($content -match $frontmatterPattern) {
        $frontmatter = $Matches[1]
        $body = $Matches[2]
        foreach ($line in ($frontmatter -split "\r?\n")) {
            if ($line -match '^description:\s*(.+)$') {
                $description = $Matches[1].Trim().Trim("'").Trim('"')
                break
            }
        }
    }

    if (-not $description) {
        $description = "Translated from ai-toolkit/default/commands/$Name.md (Claude Code slash command) for Codex CLI."
    }

    $newFrontmatterLines = @(
        '---'
        "name: $Name"
        "description: $description"
        '---'
        ''
    )
    $translated = ($newFrontmatterLines -join "`n") + $body

    $destDir = Split-Path -Parent $DestinationPath
    if (-not (Test-Path -LiteralPath $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }
    Set-Content -LiteralPath $DestinationPath -Value $translated -NoNewline -Encoding utf8
}

# ---------------------------------------------------------------------------
# Per-file comparison (byte-for-byte via Get-FileHash, per plan.md decision #7)
# ---------------------------------------------------------------------------

function Test-CatalogFile {
    param(
        [Parameter(Mandatory = $true)][string]$RelPath,
        [Parameter(Mandatory = $true)][ValidateSet('commands', 'agents')][string]$Category,
        [Parameter(Mandatory = $true)][ValidateSet('claude', 'codex')][string]$Target,
        [Parameter(Mandatory = $true)][string]$RunRoot
    )

    $sourcePath = Convert-ToRepoPath -RelativePath $RelPath
    $name = [System.IO.Path]::GetFileNameWithoutExtension($RelPath)
    $leaf = Split-Path -Leaf $RelPath

    $applicable = $true
    $installedPath = $null
    $note = ''

    if ($Target -eq 'claude') {
        $installedPath = Join-Path $RunRoot ".claude\$Category\$leaf"
    } else {
        if ($Category -eq 'commands') {
            $installedPath = Join-Path $RunRoot ".codex\skills\$name\SKILL.md"
        } else {
            $applicable = $false
            $note = "Codex CLI has no subagent equivalent (setup-ai.md Step 5 / ADR-002) - not installed for this target by design, not a failure."
        }
    }

    $sourcePresent = Test-Path -LiteralPath $sourcePath
    $installedPresent = $false
    $match = $false
    $status = $null

    if (-not $sourcePresent) {
        $status = 'SOURCE_MISSING'
        $note = "Catalog declares '$RelPath' but it does not exist under ai-toolkit/default/ (catalog drift)."
    } elseif (-not $applicable) {
        $status = 'NOT_APPLICABLE'
    } else {
        $installedPresent = Test-Path -LiteralPath $installedPath
        if (-not $installedPresent) {
            $status = 'MISSING'
            $note = 'Source exists but was not written to the scratch destination.'
        } else {
            $sourceHash = (Get-FileHash -LiteralPath $sourcePath -Algorithm SHA256).Hash
            $installedHash = (Get-FileHash -LiteralPath $installedPath -Algorithm SHA256).Hash
            $match = ($sourceHash -eq $installedHash)
            if ($match) {
                $status = 'MATCH'
            } else {
                $status = 'MISMATCH'
                if ($Target -eq 'codex') {
                    $note = 'Expected: Codex translation rewrites the frontmatter, so the hash legitimately differs from the Claude Code source (best-effort, ADR-002).'
                } else {
                    $note = 'Installed content differs from the ai-toolkit/default/ source.'
                }
            }
        }
    }

    return [pscustomobject]@{
        RelPath          = $RelPath
        Category         = $Category
        InstalledPath    = $installedPath
        Applicable       = $applicable
        SourcePresent    = $sourcePresent
        InstalledPresent = $installedPresent
        Match            = $match
        Status           = $status
        Note             = $note
    }
}

# ---------------------------------------------------------------------------
# Evidence.md rendering
# ---------------------------------------------------------------------------

function New-MarkdownTable {
    param([Parameter(Mandatory = $true)][System.Collections.Generic.List[pscustomobject]]$Rows)

    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine('| Category | Catalog source | Installed path | Source present | Installed present | Match | Status | Note |')
    [void]$sb.AppendLine('|---|---|---|---|---|---|---|---|')
    foreach ($r in $Rows) {
        $installedDisplay = 'n/a'
        if ($r.InstalledPath) {
            $installedDisplay = $r.InstalledPath.Substring($ScratchRoot.Length).TrimStart('\')
        }
        $sourcePresentDisplay = 'no'
        if ($r.SourcePresent) { $sourcePresentDisplay = 'yes' }
        $installedPresentDisplay = 'no'
        if ($r.InstalledPresent) { $installedPresentDisplay = 'yes' }
        $matchDisplay = 'no'
        if ($r.Match) { $matchDisplay = 'yes' }
        $noteDisplay = $r.Note -replace '\|', '\|'
        [void]$sb.AppendLine("| $($r.Category) | ``$($r.RelPath)`` | ``$installedDisplay`` | $sourcePresentDisplay | $installedPresentDisplay | $matchDisplay | $($r.Status) | $noteDisplay |")
    }
    return $sb.ToString()
}

function Add-EvidenceSection {
    param(
        [Parameter(Mandatory = $true)][string]$Target,
        [Parameter(Mandatory = $true)][string]$Method,
        [Parameter(Mandatory = $true)][string]$RunRoot,
        [Parameter(Mandatory = $true)][System.Collections.Generic.List[pscustomobject]]$Rows,
        [Parameter(Mandatory = $true)][bool]$Blocking,
        [Parameter(Mandatory = $true)][bool]$AggregatePass,
        [Parameter(Mandatory = $false)][string]$FatalError = $null
    )

    $evidenceDir = Split-Path -Parent $EvidencePath
    if (-not (Test-Path -LiteralPath $evidenceDir)) {
        New-Item -ItemType Directory -Path $evidenceDir -Force | Out-Null
    }

    if (-not (Test-Path -LiteralPath $EvidencePath)) {
        $header = @(
            '# Evidence - Automated install verification check'
            ''
            'Permanent record of the Phase 1 gate defined in `specs/005-automated-install-verification-check/requirements.md`.'
            'Generated and appended to by `scripts/verify-install-temp.ps1` (temporary - deleted once the gate is judged PASS,'
            'see `specs/005-automated-install-verification-check/plan.md`, Batch 4). This file is NOT deleted with the script;'
            'it is the record that the check ran (SC-001-SC-004).'
            ''
            'Each section below covers one `(target, method)` run. Claude Code runs are blocking for the gate; Codex CLI runs'
            'are best-effort and non-blocking (FR-007, ADR-002) regardless of their outcome.'
            ''
        ) -join "`n"
        Set-Content -LiteralPath $EvidencePath -Value $header -Encoding utf8
    }

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $sectionLines = New-Object System.Collections.Generic.List[string]
    [void]$sectionLines.Add("## Run: target=$Target, method=$Method - $timestamp")
    [void]$sectionLines.Add('')
    [void]$sectionLines.Add("- Scratch folder: ``$RunRoot``")
    [void]$sectionLines.Add("- Blocking for the Phase 1 gate: $(if ($Blocking) { 'yes (Claude Code)' } else { 'no (Codex CLI, best-effort per ADR-002/FR-007)' })")
    [void]$sectionLines.Add('')

    if ($FatalError) {
        [void]$sectionLines.Add("**Result: ERROR** - the run could not complete: $FatalError")
        [void]$sectionLines.Add('')
    } else {
        [void]$sectionLines.Add((New-MarkdownTable -Rows $Rows))

        $total = $Rows.Count
        $matched = ($Rows | Where-Object { $_.Status -eq 'MATCH' }).Count
        $notApplicable = ($Rows | Where-Object { $_.Status -eq 'NOT_APPLICABLE' }).Count
        $failing = $total - $matched - $notApplicable

        $aggregateLabel = if ($AggregatePass) { 'PASS' } else { 'FAIL' }
        [void]$sectionLines.Add("**Result: $aggregateLabel** - $matched/$total files present and byte-for-byte identical to their ai-toolkit/default/ source" + $(if ($notApplicable -gt 0) { " ($notApplicable not applicable to this target, $failing failing/mismatched)." } else { " ($failing failing/mismatched)." }))
        [void]$sectionLines.Add('')
    }

    Add-Content -LiteralPath $EvidencePath -Value ($sectionLines -join "`n") -Encoding utf8
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

$runFolderName = "$Target-$Method"
$RunRoot = Join-Path $ScratchRoot $runFolderName

Write-Host "=== verify-install-temp.ps1 : target=$Target method=$Method ===" -ForegroundColor Cyan
Write-Host "Repo root:    $RepoRoot"
Write-Host "Catalog:      $CatalogPath"
Write-Host "Scratch run:  $RunRoot"

try {
    # --- Parse catalog ------------------------------------------------------
    $catalog = Get-CatalogEntries -CatalogPath $CatalogPath -ProfileName $ProfileName

    if ($catalog.Commands.Count -eq 0 -and $catalog.Agents.Count -eq 0) {
        throw "catalog.yaml has no commands/agents declared for profile '$ProfileName'. Nothing to verify - check that catalog.yaml (002) exists and declares the 'default' profile."
    }

    Write-Host "Catalog entries for profile '$ProfileName': $($catalog.Commands.Count) commands, $($catalog.Agents.Count) agents"

    # --- Fresh scratch folder (decision #3: never reuse a prior run) -------
    if (Test-Path -LiteralPath $RunRoot) {
        Remove-Item -LiteralPath $RunRoot -Recurse -Force
    }
    New-Item -ItemType Directory -Path $RunRoot -Force | Out-Null

    # --- Install ("write files") --------------------------------------------
    if ($Target -eq 'claude') {
        $claudeCommandsDest = Join-Path $RunRoot '.claude\commands'
        $claudeAgentsDest = Join-Path $RunRoot '.claude\agents'
        New-Item -ItemType Directory -Path $claudeCommandsDest -Force | Out-Null
        New-Item -ItemType Directory -Path $claudeAgentsDest -Force | Out-Null

        foreach ($relPath in $catalog.Commands) {
            $srcFile = Convert-ToRepoPath -RelativePath $relPath
            if (-not (Test-Path -LiteralPath $srcFile)) {
                Write-Warning "Catalog source missing, cannot install: $relPath"
                continue
            }
            $destFile = Join-Path $claudeCommandsDest (Split-Path -Leaf $relPath)
            Copy-Item -LiteralPath $srcFile -Destination $destFile -Force
        }
        foreach ($relPath in $catalog.Agents) {
            $srcFile = Convert-ToRepoPath -RelativePath $relPath
            if (-not (Test-Path -LiteralPath $srcFile)) {
                Write-Warning "Catalog source missing, cannot install: $relPath"
                continue
            }
            $destFile = Join-Path $claudeAgentsDest (Split-Path -Leaf $relPath)
            Copy-Item -LiteralPath $srcFile -Destination $destFile -Force
        }
    } else {
        # Codex: only `commands` translate into skills (setup-ai.md Step 5 -
        # Codex CLI has no subagent equivalent, so `agents` are intentionally
        # not written here at all).
        $codexSkillsDest = Join-Path $RunRoot '.codex\skills'
        New-Item -ItemType Directory -Path $codexSkillsDest -Force | Out-Null

        foreach ($relPath in $catalog.Commands) {
            $srcFile = Convert-ToRepoPath -RelativePath $relPath
            if (-not (Test-Path -LiteralPath $srcFile)) {
                Write-Warning "Catalog source missing, cannot translate: $relPath"
                continue
            }
            $name = [System.IO.Path]::GetFileNameWithoutExtension($relPath)
            $skillFile = Join-Path $codexSkillsDest "$name\SKILL.md"
            ConvertTo-CodexSkill -SourcePath $srcFile -DestinationPath $skillFile -Name $name
        }
    }

    # --- Compare (byte-for-byte, walking every catalog-declared file) ------
    $rows = New-Object System.Collections.Generic.List[pscustomobject]
    foreach ($relPath in $catalog.Commands) {
        [void]$rows.Add((Test-CatalogFile -RelPath $relPath -Category 'commands' -Target $Target -RunRoot $RunRoot))
    }
    foreach ($relPath in $catalog.Agents) {
        [void]$rows.Add((Test-CatalogFile -RelPath $relPath -Category 'agents' -Target $Target -RunRoot $RunRoot))
    }

    # --- Console summary -----------------------------------------------------
    $rows | Format-Table -Property Category, RelPath, Status, Match -AutoSize | Out-String | Write-Host

    $failingRows = $rows | Where-Object { $_.Status -notin @('MATCH', 'NOT_APPLICABLE') }
    $aggregatePass = ($failingRows.Count -eq 0)

    $blocking = ($Target -eq 'claude')

    if ($aggregatePass) {
        Write-Host "RESULT: PASS - all $($rows.Count) catalog-declared files present and byte-for-byte identical to source." -ForegroundColor Green
    } else {
        Write-Host "RESULT: FAIL - $($failingRows.Count)/$($rows.Count) catalog-declared files missing or mismatched." -ForegroundColor Yellow
        foreach ($fr in $failingRows) {
            Write-Host "  - [$($fr.Status)] $($fr.RelPath) : $($fr.Note)" -ForegroundColor Yellow
        }
    }

    # --- Evidence -------------------------------------------------------------
    Add-EvidenceSection -Target $Target -Method $Method -RunRoot $RunRoot -Rows $rows -Blocking $blocking -AggregatePass $aggregatePass
    Write-Host "Evidence appended to: $EvidencePath"

    # --- Exit code (g): claude is blocking, codex is always non-blocking ----
    if ($Target -eq 'codex') {
        exit 0
    }
    if ($aggregatePass) {
        exit 0
    }
    exit 1
} catch {
    $errorMessage = $_.Exception.Message
    Write-Host "FATAL: $errorMessage" -ForegroundColor Red

    try {
        Add-EvidenceSection -Target $Target -Method $Method -RunRoot $RunRoot -Rows (New-Object System.Collections.Generic.List[pscustomobject]) -Blocking ($Target -eq 'claude') -AggregatePass $false -FatalError $errorMessage
    } catch {
        Write-Host "(Could not append fatal-error section to evidence.md: $($_.Exception.Message))" -ForegroundColor Red
    }

    # FR-007: Codex CLI is non-blocking regardless of result, including a
    # fatal error in this best-effort run.
    if ($Target -eq 'codex') {
        exit 0
    }
    exit 1
}
