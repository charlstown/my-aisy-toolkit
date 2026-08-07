# Validación manual reproducible — Step 6 (lanzador global)

## Propósito y alcance

El repositorio no dispone de un ejecutable de `setup-ai` ni de infraestructura de pruebas automatizadas para instrucciones que interpreta un agente. Esta guía es la cobertura de regresión repetible de Step 6. Se ejecuta contra una copia local de `setup-ai.md`, en un HOME desechable, y nunca contra el HOME real.

Cubre el panel ASCII, una única confirmación, la detección previa de ambos agentes, las rutas ausentes, la escritura idempotente y la comunicación de un fallo de detectabilidad posterior. La ejecución e invocación reales desde otro repositorio corresponde a la tarea `@tester` del plan.

## Preparación común

Abrir una nueva ventana de PowerShell y ejecutar lo siguiente. No reutilizar una consola que haya iniciado Claude Code o Codex antes de cambiar `HOME`.

```powershell
$repo = (Resolve-Path .).Path
$run = Join-Path ([System.IO.Path]::GetTempPath()) ("setup-ai-step6-" + [guid]::NewGuid())
$testHome = Join-Path $run "home"
$firstRepo = Join-Path $run "repo-a"
$secondRepo = Join-Path $run "repo-b"
New-Item -ItemType Directory -Force -Path $testHome, $firstRepo, $secondRepo | Out-Null

# The process that runs the agent must inherit these values.
$env:HOME = $testHome
$env:USERPROFILE = $testHome
$env:HOMEDRIVE = [System.IO.Path]::GetPathRoot($testHome).TrimEnd('\\')
$env:HOMEPATH = $testHome.Substring($env:HOMEDRIVE.Length)

Set-Location $firstRepo
git init -q
```

In each case below, ask a fresh Claude Code or Codex session (started from this shell) to follow the local file, so the unmerged change is tested:

```text
Fetch and follow the setup instructions from: <absolute path to repo>\setup-ai.md
```

Answer all Steps 1–5 normally, then observe Step 6. Keep a transcript of the Step 6 messages and save the values of `$run`, `$testHome`, and the agent/version used. Do not substitute the real `~`, `%USERPROFILE%`, or an actual user-level agent directory.

For the byte checks below, extract the two literal templates from `setup-ai.md` without normalising its mixed line endings. The following writes the contents of each fenced block (including its terminating linefeed and excluding the fence) to the temporary run directory. `Get-FileHash -Algorithm SHA256` is the byte-level comparison authority.

```powershell
$source = [IO.File]::ReadAllText((Join-Path $repo 'setup-ai.md'), [Text.UTF8Encoding]::new($false))
function Save-LauncherTemplate([string] $heading, [string] $destination) {
  $headingStart = $source.IndexOf($heading, [StringComparison]::Ordinal)
  if ($headingStart -lt 0) { throw "Template heading not found: $heading" }
  $fence = '```markdown' + [char]13 + [char]10
  $fenceStart = $source.IndexOf($fence, $headingStart, [StringComparison]::Ordinal)
  if ($fenceStart -lt 0) { throw "Template opening fence not found: $heading" }
  $contentStart = $fenceStart + $fence.Length
  $contentEnd = $source.IndexOf("```", $contentStart, [StringComparison]::Ordinal)
  if ($contentEnd -lt 0) { throw "Template closing fence not found: $heading" }
  [IO.File]::WriteAllText($destination, $source.Substring($contentStart, $contentEnd - $contentStart), [Text.UTF8Encoding]::new($false))
}
Save-LauncherTemplate '#### Claude launcher template' (Join-Path $run 'claude-template.md')
Save-LauncherTemplate '#### Codex launcher template' (Join-Path $run 'codex-template.md')
```

After each case, inspect only the temporary run directory:

```powershell
Get-ChildItem -Force -Recurse $testHome
```

## Case matrix

| ID | HOME fixture before running Step 6 | Expected Step 6 result |
| --- | --- | --- |
| S6-01A | Create `$testHome\.claude` and `$testHome\.codex`. | The panel is shown before exactly one global-install authorization. An explicit yes creates both native launchers and reports the applicable successful outcome. |
| S6-01B | Create `$testHome\.claude` and `$testHome\.agents`, leaving `.codex` absent. | The same preflight succeeds and writes the Codex launcher to the fallback `.agents` destination; it does not create `.codex`. |
| S6-02 | From the successful S6-01A fixture, run Step 6 a second time and answer yes. | Both launchers remain byte-identical and are reported `unchanged`; no rewrite is performed. |
| S6-03 | Create only `$testHome\.codex`. | No launcher is written. The response names the missing Claude path and asks to initialize/install it and rerun. No panel or authorization is shown. |
| S6-04 | Create only `$testHome\.claude`. | No launcher is written. The response names the missing Codex path and asks to initialize/install it and rerun. No panel or authorization is shown. |
| S6-05 | Leave both roots absent. | No launcher is written. The response contains both missing-path causes and asks to initialize/install the missing agents and rerun. No panel or authorization is shown. |
| S6-06 | Same as S6-01A, but make the agent's available discovery/refresh check return “not found” after the files are copied. | Both independent file/byte/structure checks still run. The affected agent reports its name, written path, and concrete discovery failure; neither launcher is deleted or rolled back. |

## S6-01A — normal dual installation and preflight UI

Start with an empty `$testHome` made in the preparation section, then create only the roots (not their `commands` or `skills` children):

```powershell
New-Item -ItemType Directory -Force -Path "$testHome\.claude", "$testHome\.codex" | Out-Null
```

At Step 6, record the output before answering. It passes only if all of these are true:

1. A box delimited by `+---`/`|` is printed before the question and includes `setup-ai`, update/reinstall wording, `Claude Code and Codex`, and `any repository in the team` (or a faithful translation).
2. There is exactly one question seeking authorization for the global launcher. It does not ask to select Claude Code, Codex, a path, or a partial installation.
3. Before the authorization is accepted, no `$testHome\.claude\commands\setup-ai.md` nor `$testHome\.codex\skills\setup-ai\SKILL.md` exists.

Answer an explicit yes. Verify both destinations and their native shapes:

```powershell
$claudeLauncher = "$testHome\.claude\commands\setup-ai.md"
$codexLauncher = "$testHome\.codex\skills\setup-ai\SKILL.md"
Test-Path -LiteralPath $claudeLauncher
Test-Path -LiteralPath $codexLauncher
Get-FileHash -Algorithm SHA256 $claudeLauncher, "$run\claude-template.md"
Get-FileHash -Algorithm SHA256 $codexLauncher, "$run\codex-template.md"
Get-Content -Raw $claudeLauncher | Select-String -SimpleMatch "description: Globally update or reinstall"
Get-Content -Raw $codexLauncher | Select-String -SimpleMatch "name: setup-ai"
```

The two pairs of SHA-256 values must match. The Claude file must retain Markdown frontmatter, and the Codex file must be named `SKILL.md` in the `setup-ai` skill directory with `name: setup-ai` frontmatter. If the active agent exposes a discovery/refresh operation, run it and record its exact output; otherwise the agent must say that discovery could only be verified by path, bytes, and structure, not claim executable discovery.

## S6-01B — Codex fallback root

Repeat S6-01A in a fresh temporary HOME but create `$testHome\.claude` and `$testHome\.agents` instead of `.codex`. The one confirmation and panel criteria remain identical. After approval, verify `$testHome\.claude\commands\setup-ai.md` and `$testHome\.agents\skills\setup-ai\SKILL.md` against the extracted templates. `$testHome\.codex` must remain absent. This verifies that Codex's fallback is considered only when its preferred root is absent.

## S6-02 — idempotent second run

Without changing the successful S6-01A launchers, record their hashes and write times, rerun the local instructions in the same temporary HOME, and answer yes once:

```powershell
$before = Get-Item $claudeLauncher, $codexLauncher | Select-Object FullName, LastWriteTimeUtc
$beforeHash = Get-FileHash -Algorithm SHA256 $claudeLauncher, $codexLauncher
# Run the agent and approve the single global authorization here.
$after = Get-Item $claudeLauncher, $codexLauncher | Select-Object FullName, LastWriteTimeUtc
$afterHash = Get-FileHash -Algorithm SHA256 $claudeLauncher, $codexLauncher
$beforeHash.Hash -join ','
$afterHash.Hash -join ','
$before
$after
```

Pass criteria: the output reports `unchanged` for the global launcher, every before/after hash is equal, and no other file appears beneath `$testHome`. Unchanged `LastWriteTimeUtc` is supporting evidence that the files were not rewritten; a changed timestamp is a failure because Step 6 requires identical files to be left untouched.

## S6-03 through S6-05 — missing-root stop conditions

Use a fresh `$testHome` for each row. Create exactly the roots shown in the matrix, run the local instructions to Step 6, and answer no question because none must be asked. Capture the output, then run:

```powershell
Test-Path -LiteralPath "$testHome\.claude\commands\setup-ai.md"
Test-Path -LiteralPath "$testHome\.codex\skills\setup-ai\SKILL.md"
Test-Path -LiteralPath "$testHome\.agents\skills\setup-ai\SKILL.md"
```

All three results must be `False`. Also verify that an absent root was not created: for example, S6-03 must leave `$testHome\.claude` absent and S6-04 must leave both `$testHome\.codex` and `$testHome\.agents` absent. The diagnostic must include exactly the applicable phrase(s):

- `missing Claude Code path (~/.claude/)`
- `missing Codex path (~/.codex/ or ~/.agents/)`

S6-05 must include both phrases in one response. Every missing-root case must tell the user to install or initialize the missing agent and run `setup-ai` again, and must neither show the panel nor solicit the global-install confirmation.

## S6-06 — supported discovery check reports not found

This case is only executable when the current agent/version offers an explicit command/skill discovery or refresh check that can be controlled to return a negative result. Create both roots as in S6-01A and use the agent's documented test/stub mechanism to make its post-copy check return `not found` for one launcher. Do not delete, rename, corrupt, or hide the destination file to manufacture the failure: that would test file validation rather than discovery.

Approve the single confirmation. The transcript must identify the relevant agent, its written launcher path, and the concrete negative check result. Verify that both launcher paths still exist, retain their expected SHA-256 values and frontmatter, and that the other agent's independent verification occurred. A failed discovery check is a reported failure, not a rollback trigger.

If the installed Claude Code/Codex version has no discovery/refresh check, record the version and capability absence. Mark S6-06 **not applicable for that run** rather than asserting detectability; S6-01 must instead show the specified limited-verification message. Do not fabricate a failure in this situation.

## Cleanup

After the transcript and evidence are retained, remove only the directory created in this guide:

```powershell
Remove-Item -LiteralPath $run -Recurse -Force
```

Before executing that command, confirm `$run` starts with the system temporary directory and contains the generated `setup-ai-step6-` prefix. Never use a recursive deletion against HOME, the repository, or an unresolved variable.
