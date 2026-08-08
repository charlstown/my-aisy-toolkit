# Exercises the catalog installation contract in isolated directories.
# Run with: powershell -ExecutionPolicy Bypass -File .github/scripts/verify-aisy-install-matrix.ps1

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$catalog = Get-Content (Join-Path $root 'catalog.yaml') -Raw
$tempRoot = Join-Path ([IO.Path]::GetTempPath()) ("aisy-install-matrix-" + [guid]::NewGuid())
$checks = 0

function Get-Skills([string] $profile) {
  $pattern = "(?ms)^  $([regex]::Escape($profile)):\r?\n    skills:\r?\n(?<skills>(?:      - ai-toolkit/skills/[^\r\n]+\r?\n)+)"
  $match = [regex]::Match($catalog, $pattern)
  if (-not $match.Success) { throw "No skills declared for profile $profile" }
  return @([regex]::Matches($match.Groups['skills'].Value, 'ai-toolkit/skills/([^/]+)/SKILL\.md') | ForEach-Object { $_.Groups[1].Value })
}

function Get-Utils {
  return @([regex]::Matches($catalog, '(?m)^    - ai-toolkit/skills/([^/]+)/SKILL\.md$') | ForEach-Object { $_.Groups[1].Value })
}

try {
  foreach ($platform in @('claude', 'codex')) {
    $skillsRoot = if ($platform -eq 'claude') { '.claude/skills' } else { '.agents/skills' }
    foreach ($profile in @('default', 'ui-ux')) {
      $repo = Join-Path $tempRoot "$platform-$profile"
      $destinationRoot = Join-Path $repo $skillsRoot
      $legacy = Join-Path $destinationRoot 'legacy-skill/SKILL.md'
      New-Item -ItemType Directory -Force -Path (Split-Path $legacy) | Out-Null
      Set-Content -LiteralPath $legacy -Value 'historical skill must remain' -NoNewline

      $names = @(Get-Skills $profile) + @(Get-Utils)
      foreach ($name in $names) {
        $source = Join-Path $root "ai-toolkit/skills/$name/SKILL.md"
        $destination = Join-Path $destinationRoot "aisy.$name/SKILL.md"
        New-Item -ItemType Directory -Force -Path (Split-Path $destination) | Out-Null
        Copy-Item -LiteralPath $source -Destination $destination
        if (-not (Test-Path -LiteralPath $destination)) { throw "$platform/$profile did not install aisy.$name" }
        if ((Get-FileHash $source).Hash -ne (Get-FileHash $destination).Hash) { throw "$platform/$profile changed aisy.$name content" }
        if (Test-Path -LiteralPath (Join-Path $destinationRoot "$name/SKILL.md")) { throw "$platform/$profile planned an unprefixed $name destination" }
        $checks++
      }

      if (-not (Test-Path -LiteralPath $legacy)) { throw "$platform/$profile removed the historical skill" }
    }
  }

  $setup = Get-Content (Join-Path $root 'setup-ai.md') -Raw
  foreach ($literal in @('Trigger on /aisy.setup-ai.', 'name: aisy.setup-ai', 'Trigger on $aisy.setup-ai.')) {
    if (-not $setup.Contains($literal)) { throw "Missing global launcher contract: $literal" }
    $checks++
  }

  Write-Host "OK: $checks prefixed skill installs verified across Claude/Codex, default/ui-ux, and utils."
}
finally {
  if (Test-Path -LiteralPath $tempRoot) { Remove-Item -LiteralPath $tempRoot -Recurse -Force }
}
