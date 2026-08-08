#!/usr/bin/env bash
#
# verify-setup-fetch-contract.test.sh -- tests the fetch-recovery contract
# written in setup-ai.md. The installer is intentionally instructions rather
# than executable code, so these checks protect its required wording and the
# byte-for-byte launcher templates without making network requests.
#
# Run locally with:
#   bash .github/scripts/verify-setup-fetch-contract.test.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_AI="$SCRIPT_DIR/../../setup-ai.md"

if [[ ! -f "$SETUP_AI" ]]; then
  echo "::error::No se encuentra setup-ai.md en $SETUP_AI" >&2
  exit 1
fi

TESTS_RUN=0
TESTS_FAILED=0

fail() {
  TESTS_FAILED=$((TESTS_FAILED + 1))
  echo "  FAIL: $1" >&2
}

assert_contains() {
  local text="$1" needle="$2" context="$3"
  if [[ "$text" != *"$needle"* ]]; then
    fail "$context: falta '$needle'"
  fi
}

assert_before() {
  local text="$1" first="$2" second="$3" context="$4"
  local before after
  before="${text%%"$first"*}"
  after="${text#*"$second"}"
  if [[ "$before" == "$text" || "$after" == "$text" || ${#before} -ge $(( ${#text} - ${#after} - ${#second} )) ]]; then
    fail "$context: '$first' debe aparecer antes de '$second'"
  fi
}

template() {
  local platform="$1"
  awk -v heading="#### ${platform} launcher template" '
    $0 == heading { in_template = 1; next }
    in_template && $0 == "```markdown" { in_code = 1; next }
    in_code && $0 == "```" { exit }
    in_code { print }
  ' "$SETUP_AI"
}

assert_recovery_contract() {
  local subject="$1" text="$2" native_fetch="$3"

  assert_contains "$text" "$native_fetch" "$subject"
  assert_contains "$text" "compatible alternative download method" "$subject"
  assert_contains "$text" "sequentially" "$subject"
  assert_contains "$text" "never in parallel" "$subject"
  assert_contains "$text" "only after every compatible method is exhausted" "$subject"
  assert_contains "$text" "CRYPT_E_NO_REVOCATION_CHECK" "$subject"
  assert_contains "$text" "fetch/schannel failure before HTTP" "$subject"
  assert_contains "$text" "never as a 4xx/5xx response" "$subject"

  assert_before "$text" "$native_fetch" "compatible alternative download method" "$subject"
  assert_before "$text" "compatible alternative download method" "only after every compatible method is exhausted" "$subject"
}

assert_bootstrap_recovery() {
  local text="$1"

  assert_contains "$text" "For this bootstrap GET" "bootstrap"
  assert_contains "$text" "native fetch capability first" "bootstrap"
  assert_contains "$text" "compatible download method" "bootstrap"
  assert_contains "$text" "sequentially" "bootstrap"
  assert_contains "$text" "stopping at the first successful download" "bootstrap"
  assert_contains "$text" "CRYPT_E_NO_REVOCATION_CHECK" "bootstrap"
  assert_contains "$text" "fetch/schannel failure before HTTP" "bootstrap"
  assert_contains "$text" "never as a 4xx/5xx response" "bootstrap"
  assert_contains "$text" "Only after every compatible method fails" "bootstrap"
  assert_contains "$text" "do not install or write an engine" "bootstrap"
  assert_before "$text" "native fetch capability first" "compatible download method" "bootstrap"
  assert_before "$text" "compatible download method" "Only after every compatible method fails" "bootstrap"
}

assert_catalog_recovery() {
  local subject="$1" text="$2"

  assert_recovery_contract "$subject: catalogo" "$text" "native fetch capability first"
  assert_contains "$text" "catalog.yaml" "$subject: catalogo"
  assert_contains "$text" "complete method chain" "$subject: catalogo"
  assert_contains "$text" "every method fails" "$subject: catalogo"
  assert_contains "$text" "writ" "$subject: catalogo"
}

assert_artifact_recovery() {
  local subject="$1" text="$2"

  assert_contains "$text" "selected" "$subject: artefactos"
  assert_contains "$text" "complete method chain" "$subject: artefactos"
  assert_contains "$text" "try" "$subject: artefactos"
  assert_contains "$text" "repeating" "$subject: artefactos"
  assert_contains "$text" "skip" "$subject: artefactos"
  assert_before "$text" "complete method chain" "repeating" "$subject: artefactos"
}

assert_launcher_update_recovery() {
  local subject="$1" text="$2" native_fetch="$3" platform="$4"

  assert_contains "$text" "Before Step 1, GET" "$subject: autoactualizacion"
  assert_contains "$text" "setup-ai.md" "$subject: autoactualizacion"
  assert_contains "$text" "literal **${platform} launcher template**" "$subject: autoactualizacion"
  assert_contains "$text" "$native_fetch" "$subject: autoactualizacion"
  assert_contains "$text" "compatible alternative download method" "$subject: autoactualizacion"
  assert_contains "$text" "sequentially" "$subject: autoactualizacion"
  assert_contains "$text" "same URL" "$subject: autoactualizacion"
  assert_contains "$text" "stopping at the first successful download" "$subject: autoactualizacion"
  assert_contains "$text" "CRYPT_E_NO_REVOCATION_CHECK" "$subject: autoactualizacion"
  assert_contains "$text" "fetch/schannel failure before HTTP" "$subject: autoactualizacion"
  assert_contains "$text" "never as a 4xx/5xx response" "$subject: autoactualizacion"
  assert_contains "$text" "Only if every compatible fetch method fails" "$subject: autoactualizacion"
  assert_contains "$text" "continue with this embedded engine" "$subject: autoactualizacion"
  assert_before "$text" "$native_fetch" "compatible alternative download method" "$subject: autoactualizacion"
  assert_before "$text" "compatible alternative download method" "Only if every compatible fetch method fails" "$subject: autoactualizacion"
}

run_test() {
  local name="$1" fn="$2"
  TESTS_RUN=$((TESTS_RUN + 1))
  local failures_before=$TESTS_FAILED
  echo "TEST: $name"
  "$fn"
  if [[ "$TESTS_FAILED" -eq "$failures_before" ]]; then
    echo "  OK"
  fi
}

test_bootstrap_recovery_contract() {
  local document bootstrap
  document="$(awk '/^#### Claude launcher template$/ { exit } { print }' "$SETUP_AI")"
  bootstrap="${document%%$'\n---'*}"
  assert_bootstrap_recovery "$bootstrap"
}

test_main_engine_catalog_and_artifact_contract() {
  local catalog artifacts
  catalog="$(awk '/^### Step 2/ { section = 1 } /^### Step 3/ { exit } section { print }' "$SETUP_AI")"
  artifacts="$(awk '/^### Step 3/ { section = 1 } /^### Step 4/ { exit } section { print }' "$SETUP_AI")"

  assert_catalog_recovery "documento principal" "$catalog"
  assert_artifact_recovery "documento principal" "$artifacts"
}

test_claude_template_contract() {
  local launcher catalog artifacts update
  launcher="$(template "Claude")"
  catalog="$(printf '%s\n' "$launcher" | awk '/^2\. For every GET/ { section = 1 } /^3\. Fetch/ { exit } section { print }')"
  artifacts="$(printf '%s\n' "$launcher" | awk '/^3\. Fetch/ { section = 1 } /^4\. Copy/ { exit } section { print }')"
  update="$(printf '%s\n' "$launcher" | awk '/^Before Step 1,/ { section = 1 } section { print }')"

  assert_contains "$launcher" "# setup-ai" "plantilla Claude"
  assert_catalog_recovery "plantilla Claude" "$catalog"
  assert_artifact_recovery "plantilla Claude" "$artifacts"
  assert_launcher_update_recovery "plantilla Claude" "$update" "Claude Code's native fetch capability first" "Claude"
}

test_codex_template_contract() {
  local launcher catalog artifacts update
  launcher="$(template "Codex")"
  catalog="$(printf '%s\n' "$launcher" | awk '/^2\. For every GET/ { section = 1 } /^3\. Fetch/ { exit } section { print }')"
  artifacts="$(printf '%s\n' "$launcher" | awk '/^3\. Fetch/ { section = 1 } /^4\. Copy/ { exit } section { print }')"
  update="$(printf '%s\n' "$launcher" | awk '/^Before Step 1,/ { section = 1 } section { print }')"

  assert_contains "$launcher" "# setup-ai" "plantilla Codex"
  assert_catalog_recovery "plantilla Codex" "$catalog"
  assert_artifact_recovery "plantilla Codex" "$artifacts"
  assert_launcher_update_recovery "plantilla Codex" "$update" "Codex CLI's native fetch capability first" "Codex"
}

run_test "bootstrap: recuperacion de fetch" test_bootstrap_recovery_contract
run_test "motor principal: catalogo y artefactos" test_main_engine_catalog_and_artifact_contract
run_test "plantilla Claude: catalogo, artefactos y autoactualizacion" test_claude_template_contract
run_test "plantilla Codex: catalogo, artefactos y autoactualizacion" test_codex_template_contract

echo
echo "----"
echo "$TESTS_RUN tests ejecutados, $TESTS_FAILED fallidos."

if [[ "$TESTS_FAILED" -gt 0 ]]; then
  exit 1
fi
