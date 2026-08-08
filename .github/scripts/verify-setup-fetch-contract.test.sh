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

test_main_document_contract() {
  local document
  document="$(awk '/^#### Claude launcher template$/ { exit } { print }' "$SETUP_AI")"
  assert_recovery_contract "setup-ai.md" "$document" "native fetch capability first"
}

test_claude_template_contract() {
  local launcher
  launcher="$(template "Claude")"
  assert_contains "$launcher" "# setup-ai" "plantilla Claude"
  assert_recovery_contract "plantilla Claude" "$launcher" "Claude Code's native fetch capability first"
}

test_codex_template_contract() {
  local launcher
  launcher="$(template "Codex")"
  assert_contains "$launcher" "# setup-ai" "plantilla Codex"
  assert_recovery_contract "plantilla Codex" "$launcher" "Codex CLI's native fetch capability first"
}

run_test "documento principal: recuperacion de fetch" test_main_document_contract
run_test "plantilla Claude: recuperacion de fetch" test_claude_template_contract
run_test "plantilla Codex: recuperacion de fetch" test_codex_template_contract

echo
echo "----"
echo "$TESTS_RUN tests ejecutados, $TESTS_FAILED fallidos."

if [[ "$TESTS_FAILED" -gt 0 ]]; then
  exit 1
fi
