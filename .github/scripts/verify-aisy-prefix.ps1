# Static contract check for the public aisy.<skill> installation convention.
# Run with: powershell -ExecutionPolicy Bypass -File .github/scripts/verify-aisy-prefix.ps1

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$catalogPath = Join-Path $root 'catalog.yaml'
$setupPath = Join-Path $root 'setup-ai.md'
$failures = [System.Collections.Generic.List[string]]::new()

function Add-Failure([string] $message) {
  $script:failures.Add($message)
  [Console]::Error.WriteLine("FAIL: $message")
}

function Require-Literal([string] $needle, [string] $content, [string] $file) {
  if (-not $content.Contains($needle)) {
    Add-Failure "missing '$needle' in $file"
  }
}

if (-not (Test-Path -LiteralPath $catalogPath) -or -not (Test-Path -LiteralPath $setupPath)) {
  Add-Failure 'catalog.yaml and setup-ai.md must exist at the repository root'
  exit 1
}

$catalog = Get-Content -LiteralPath $catalogPath -Raw
$setup = Get-Content -LiteralPath $setupPath -Raw
$skillNames = @(
  [regex]::Matches($catalog, '(?m)^\s*-\s+ai-toolkit/skills/([^/]+)/SKILL\.md\s*$') |
    ForEach-Object { $_.Groups[1].Value } |
    Sort-Object -Unique
)

if ($skillNames.Count -eq 0) {
  Add-Failure 'catalog.yaml does not declare any distributed skills'
}

foreach ($destination in @('.claude/skills/aisy.<name>/SKILL.md', '.agents/skills/aisy.<name>/SKILL.md')) {
  Require-Literal $destination $setup 'setup-ai.md'
}
Require-Literal 'copy bytes literally' $setup 'setup-ai.md'
Require-Literal 'Trigger on /aisy.setup-ai.' $setup 'setup-ai.md'
Require-Literal 'name: aisy.setup-ai' $setup 'setup-ai.md'
Require-Literal 'Trigger on $aisy.setup-ai.' $setup 'setup-ai.md'

$publicFiles = @(
  Get-ChildItem -LiteralPath (Join-Path $root 'ai-toolkit/skills') -Recurse -Filter SKILL.md -File |
    Select-Object -ExpandProperty FullName
) + @(
  (Join-Path $root 'README.md'),
  (Join-Path $root 'README-ES.md'),
  (Join-Path $root 'ai-toolkit/README.md'),
  $setupPath
)

foreach ($skillName in $skillNames) {
  $slashPattern = "(^|[^a-zA-Z0-9:._-])/$([regex]::Escape($skillName))([^a-zA-Z0-9:._-]|$)"
  $dollarPattern = '(^|[^a-zA-Z0-9:._-])\$' + [regex]::Escape($skillName) + '([^a-zA-Z0-9:._-]|$)'
  foreach ($file in $publicFiles) {
    $relative = $file.Substring($root.Length).TrimStart([char[]]'\\/')
    $line = 0
    foreach ($text in Get-Content -LiteralPath $file) {
      $line++
      if ($text -match $slashPattern) { Add-Failure "unprefixed /$skillName invocation: $relative`:$line" }
      if ($text -match $dollarPattern) { Add-Failure "unprefixed `$$skillName invocation: $relative`:$line" }
    }
  }
}

if ($failures.Count -gt 0) {
  Write-Host "`n$($failures.Count) static aisy-prefix check(s) failed."
  exit 1
}

Write-Host "OK: $($skillNames.Count) catalog skills use aisy-prefixed destinations, launchers, and public commands."
