#!/usr/bin/env bash
#
# Static contract check for the public aisy.<skill> installation convention.
# Run with: bash .github/scripts/verify-aisy-prefix.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CATALOG="$ROOT/catalog.yaml"
SETUP="$ROOT/setup-ai.md"
FAILURES=0

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  FAILURES=$((FAILURES + 1))
}

require_literal() {
  local needle="$1" file="$2"
  grep -Fq -- "$needle" "$file" || fail "missing '$needle' in ${file#$ROOT/}"
}

if [[ ! -f "$CATALOG" || ! -f "$SETUP" ]]; then
  fail "catalog.yaml and setup-ai.md must exist at the repository root"
  exit 1
fi

mapfile -t SKILL_NAMES < <(
  sed -nE 's|^[[:space:]]*-[[:space:]]+ai-toolkit/skills/([^/]+)/SKILL\.md$|\1|p' "$CATALOG" | sort -u
)

if [[ "${#SKILL_NAMES[@]}" -eq 0 ]]; then
  fail "catalog.yaml does not declare any distributed skills"
fi

# Both engines must calculate an aisy-prefixed destination for every catalog
# selection. A literal copy rule protects the content requirement too.
for destination in '.claude/skills/aisy.<name>/SKILL.md' '.agents/skills/aisy.<name>/SKILL.md'; do
  require_literal "$destination" "$SETUP"
done
require_literal 'copy bytes literally' "$SETUP"

# The embedded global launchers are public skills as well.
require_literal 'Trigger on /aisy.setup-ai.' "$SETUP"
require_literal 'name: aisy.setup-ai' "$SETUP"
require_literal 'Trigger on $aisy.setup-ai.' "$SETUP"

# Public invocations in distributed skills and top-level documentation must
# always include the prefix when they name an installed catalog skill.
mapfile -t PUBLIC_FILES < <(
  find "$ROOT/ai-toolkit/skills" -name SKILL.md -type f -print
  printf '%s\n' "$ROOT/README.md" "$ROOT/README-ES.md" "$ROOT/ai-toolkit/README.md" "$SETUP"
)

for name in "${SKILL_NAMES[@]}"; do
  # Matches /name and $name but not /aisy.name or $aisy.name. Keep the
  # trailing class so examples such as '/name foo' are also caught.
  pattern='(^|[^[:alnum:]._-])[/][$]?'
  # Search separately for slash and dollar invocations to avoid treating
  # prose paths as commands.
  while IFS= read -r hit; do
    fail "unprefixed /${name} invocation: ${hit#$ROOT/}"
  done < <(grep -nEH "(^|[^[:alnum:]._-])/${name}([^[:alnum:]._-]|$)" "${PUBLIC_FILES[@]}" || true)
  while IFS= read -r hit; do
    fail "unprefixed \$${name} invocation: ${hit#$ROOT/}"
  done < <(grep -nEH "(^|[^[:alnum:]._-])\\\$${name}([^[:alnum:]._-]|$)" "${PUBLIC_FILES[@]}" || true)
done

if [[ "$FAILURES" -gt 0 ]]; then
  printf '\n%s static aisy-prefix check(s) failed.\n' "$FAILURES" >&2
  exit 1
fi

printf 'OK: %s catalog skills use aisy-prefixed destinations, launchers, and public commands.\n' "${#SKILL_NAMES[@]}"
