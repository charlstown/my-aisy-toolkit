# Evidence - Automated install verification check

Permanent record of the Phase 1 gate defined in `specs/005-automated-install-verification-check/requirements.md`.
Generated and appended to by `scripts/verify-install-temp.ps1` (temporary - deleted once the gate is judged PASS,
see `specs/005-automated-install-verification-check/plan.md`, Batch 4). This file is NOT deleted with the script;
it is the record that the check ran (SC-001-SC-004).

Each section below covers one `(target, method)` run. Claude Code runs are blocking for the gate; Codex CLI runs
are best-effort and non-blocking (FR-007, ADR-002) regardless of their outcome.

## Run: target=claude, method=oneliner - 2026-08-01 14:58:52

- Scratch folder: `C:\Users\carlo\AppData\Local\Temp\my-aisy-toolkit-verify\claude-oneliner`
- Blocking for the Phase 1 gate: yes (Claude Code)

| Category | Catalog source | Installed path | Source present | Installed present | Match | Status | Note |
|---|---|---|---|---|---|---|---|
| commands | `ai-toolkit/default/commands/constitution.md` | `claude-oneliner\.claude\commands\constitution.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/product-spec.md` | `claude-oneliner\.claude\commands\product-spec.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/tech-spec.md` | `claude-oneliner\.claude\commands\tech-spec.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/roadmap.md` | `claude-oneliner\.claude\commands\roadmap.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/get-issues.md` | `claude-oneliner\.claude\commands\get-issues.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/new-issue.md` | `claude-oneliner\.claude\commands\new-issue.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/specify-feature.md` | `claude-oneliner\.claude\commands\specify-feature.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/clarify-feature.md` | `claude-oneliner\.claude\commands\clarify-feature.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/grill-me.md` | `claude-oneliner\.claude\commands\grill-me.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/plan-feature.md` | `claude-oneliner\.claude\commands\plan-feature.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/implement-feature.md` | `claude-oneliner\.claude\commands\implement-feature.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/clean-feature.md` | `claude-oneliner\.claude\commands\clean-feature.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/architect.md` | `claude-oneliner\.claude\agents\architect.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/code-developer.md` | `claude-oneliner\.claude\agents\code-developer.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/test-developer.md` | `claude-oneliner\.claude\agents\test-developer.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/tester.md` | `claude-oneliner\.claude\agents\tester.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/ui-developer.md` | `claude-oneliner\.claude\agents\ui-developer.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/judge.md` | `claude-oneliner\.claude\agents\judge.md` | yes | yes | yes | MATCH |  |

**Result: PASS** - 18/18 files present and byte-for-byte identical to their ai-toolkit/default/ source (0 failing/mismatched).

## Run: target=claude, method=oneliner - 2026-08-01 14:58:57

- Scratch folder: `C:\Users\carlo\AppData\Local\Temp\my-aisy-toolkit-verify\claude-oneliner`
- Blocking for the Phase 1 gate: yes (Claude Code)

| Category | Catalog source | Installed path | Source present | Installed present | Match | Status | Note |
|---|---|---|---|---|---|---|---|
| commands | `ai-toolkit/default/commands/constitution.md` | `claude-oneliner\.claude\commands\constitution.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/product-spec.md` | `claude-oneliner\.claude\commands\product-spec.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/tech-spec.md` | `claude-oneliner\.claude\commands\tech-spec.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/roadmap.md` | `claude-oneliner\.claude\commands\roadmap.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/get-issues.md` | `claude-oneliner\.claude\commands\get-issues.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/new-issue.md` | `claude-oneliner\.claude\commands\new-issue.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/specify-feature.md` | `claude-oneliner\.claude\commands\specify-feature.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/clarify-feature.md` | `claude-oneliner\.claude\commands\clarify-feature.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/grill-me.md` | `claude-oneliner\.claude\commands\grill-me.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/plan-feature.md` | `claude-oneliner\.claude\commands\plan-feature.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/implement-feature.md` | `claude-oneliner\.claude\commands\implement-feature.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/clean-feature.md` | `claude-oneliner\.claude\commands\clean-feature.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/architect.md` | `claude-oneliner\.claude\agents\architect.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/code-developer.md` | `claude-oneliner\.claude\agents\code-developer.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/test-developer.md` | `claude-oneliner\.claude\agents\test-developer.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/tester.md` | `claude-oneliner\.claude\agents\tester.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/ui-developer.md` | `claude-oneliner\.claude\agents\ui-developer.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/judge.md` | `claude-oneliner\.claude\agents\judge.md` | yes | yes | yes | MATCH |  |

**Result: PASS** - 18/18 files present and byte-for-byte identical to their ai-toolkit/default/ source (0 failing/mismatched).

## Run: target=claude, method=oneliner - 2026-08-01 14:59:11

- Scratch folder: `C:\Users\carlo\AppData\Local\Temp\my-aisy-toolkit-verify\claude-oneliner`
- Blocking for the Phase 1 gate: yes (Claude Code)

| Category | Catalog source | Installed path | Source present | Installed present | Match | Status | Note |
|---|---|---|---|---|---|---|---|
| commands | `ai-toolkit/default/commands/constitution.md` | `claude-oneliner\.claude\commands\constitution.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/product-spec.md` | `claude-oneliner\.claude\commands\product-spec.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/tech-spec.md` | `claude-oneliner\.claude\commands\tech-spec.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/roadmap.md` | `claude-oneliner\.claude\commands\roadmap.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/get-issues.md` | `claude-oneliner\.claude\commands\get-issues.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/new-issue.md` | `claude-oneliner\.claude\commands\new-issue.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/specify-feature.md` | `claude-oneliner\.claude\commands\specify-feature.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/clarify-feature.md` | `claude-oneliner\.claude\commands\clarify-feature.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/grill-me.md` | `claude-oneliner\.claude\commands\grill-me.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/plan-feature.md` | `claude-oneliner\.claude\commands\plan-feature.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/implement-feature.md` | `claude-oneliner\.claude\commands\implement-feature.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/clean-feature.md` | `claude-oneliner\.claude\commands\clean-feature.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/architect.md` | `claude-oneliner\.claude\agents\architect.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/code-developer.md` | `claude-oneliner\.claude\agents\code-developer.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/test-developer.md` | `claude-oneliner\.claude\agents\test-developer.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/tester.md` | `claude-oneliner\.claude\agents\tester.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/ui-developer.md` | `claude-oneliner\.claude\agents\ui-developer.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/judge.md` | `claude-oneliner\.claude\agents\judge.md` | yes | yes | yes | MATCH |  |

**Result: PASS** - 18/18 files present and byte-for-byte identical to their ai-toolkit/default/ source (0 failing/mismatched).

## Run: target=claude, method=copypaste - 2026-08-01 15:00:10

- Scratch folder: `C:\Users\carlo\AppData\Local\Temp\my-aisy-toolkit-verify\claude-copypaste`
- Blocking for the Phase 1 gate: yes (Claude Code)

| Category | Catalog source | Installed path | Source present | Installed present | Match | Status | Note |
|---|---|---|---|---|---|---|---|
| commands | `ai-toolkit/default/commands/constitution.md` | `claude-copypaste\.claude\commands\constitution.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/product-spec.md` | `claude-copypaste\.claude\commands\product-spec.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/tech-spec.md` | `claude-copypaste\.claude\commands\tech-spec.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/roadmap.md` | `claude-copypaste\.claude\commands\roadmap.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/get-issues.md` | `claude-copypaste\.claude\commands\get-issues.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/new-issue.md` | `claude-copypaste\.claude\commands\new-issue.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/specify-feature.md` | `claude-copypaste\.claude\commands\specify-feature.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/clarify-feature.md` | `claude-copypaste\.claude\commands\clarify-feature.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/grill-me.md` | `claude-copypaste\.claude\commands\grill-me.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/plan-feature.md` | `claude-copypaste\.claude\commands\plan-feature.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/implement-feature.md` | `claude-copypaste\.claude\commands\implement-feature.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/clean-feature.md` | `claude-copypaste\.claude\commands\clean-feature.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/architect.md` | `claude-copypaste\.claude\agents\architect.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/code-developer.md` | `claude-copypaste\.claude\agents\code-developer.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/test-developer.md` | `claude-copypaste\.claude\agents\test-developer.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/tester.md` | `claude-copypaste\.claude\agents\tester.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/ui-developer.md` | `claude-copypaste\.claude\agents\ui-developer.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/judge.md` | `claude-copypaste\.claude\agents\judge.md` | yes | yes | yes | MATCH |  |

**Result: PASS** - 18/18 files present and byte-for-byte identical to their ai-toolkit/default/ source (0 failing/mismatched).

## Run: target=claude, method=copypaste - 2026-08-01 15:00:19

- Scratch folder: `C:\Users\carlo\AppData\Local\Temp\my-aisy-toolkit-verify\claude-copypaste`
- Blocking for the Phase 1 gate: yes (Claude Code)

| Category | Catalog source | Installed path | Source present | Installed present | Match | Status | Note |
|---|---|---|---|---|---|---|---|
| commands | `ai-toolkit/default/commands/constitution.md` | `claude-copypaste\.claude\commands\constitution.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/product-spec.md` | `claude-copypaste\.claude\commands\product-spec.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/tech-spec.md` | `claude-copypaste\.claude\commands\tech-spec.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/roadmap.md` | `claude-copypaste\.claude\commands\roadmap.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/get-issues.md` | `claude-copypaste\.claude\commands\get-issues.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/new-issue.md` | `claude-copypaste\.claude\commands\new-issue.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/specify-feature.md` | `claude-copypaste\.claude\commands\specify-feature.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/clarify-feature.md` | `claude-copypaste\.claude\commands\clarify-feature.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/grill-me.md` | `claude-copypaste\.claude\commands\grill-me.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/plan-feature.md` | `claude-copypaste\.claude\commands\plan-feature.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/implement-feature.md` | `claude-copypaste\.claude\commands\implement-feature.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/clean-feature.md` | `claude-copypaste\.claude\commands\clean-feature.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/architect.md` | `claude-copypaste\.claude\agents\architect.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/code-developer.md` | `claude-copypaste\.claude\agents\code-developer.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/test-developer.md` | `claude-copypaste\.claude\agents\test-developer.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/tester.md` | `claude-copypaste\.claude\agents\tester.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/ui-developer.md` | `claude-copypaste\.claude\agents\ui-developer.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/judge.md` | `claude-copypaste\.claude\agents\judge.md` | yes | yes | yes | MATCH |  |

**Result: PASS** - 18/18 files present and byte-for-byte identical to their ai-toolkit/default/ source (0 failing/mismatched).

## Run: target=claude, method=copypaste - 2026-08-01 15:00:25

- Scratch folder: `C:\Users\carlo\AppData\Local\Temp\my-aisy-toolkit-verify\claude-copypaste`
- Blocking for the Phase 1 gate: yes (Claude Code)

| Category | Catalog source | Installed path | Source present | Installed present | Match | Status | Note |
|---|---|---|---|---|---|---|---|
| commands | `ai-toolkit/default/commands/constitution.md` | `claude-copypaste\.claude\commands\constitution.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/product-spec.md` | `claude-copypaste\.claude\commands\product-spec.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/tech-spec.md` | `claude-copypaste\.claude\commands\tech-spec.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/roadmap.md` | `claude-copypaste\.claude\commands\roadmap.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/get-issues.md` | `claude-copypaste\.claude\commands\get-issues.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/new-issue.md` | `claude-copypaste\.claude\commands\new-issue.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/specify-feature.md` | `claude-copypaste\.claude\commands\specify-feature.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/clarify-feature.md` | `claude-copypaste\.claude\commands\clarify-feature.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/grill-me.md` | `claude-copypaste\.claude\commands\grill-me.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/plan-feature.md` | `claude-copypaste\.claude\commands\plan-feature.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/implement-feature.md` | `claude-copypaste\.claude\commands\implement-feature.md` | yes | yes | yes | MATCH |  |
| commands | `ai-toolkit/default/commands/clean-feature.md` | `claude-copypaste\.claude\commands\clean-feature.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/architect.md` | `claude-copypaste\.claude\agents\architect.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/code-developer.md` | `claude-copypaste\.claude\agents\code-developer.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/test-developer.md` | `claude-copypaste\.claude\agents\test-developer.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/tester.md` | `claude-copypaste\.claude\agents\tester.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/ui-developer.md` | `claude-copypaste\.claude\agents\ui-developer.md` | yes | yes | yes | MATCH |  |
| agents | `ai-toolkit/default/agents/judge.md` | `claude-copypaste\.claude\agents\judge.md` | yes | yes | yes | MATCH |  |

**Result: PASS** - 18/18 files present and byte-for-byte identical to their ai-toolkit/default/ source (0 failing/mismatched).

## Run: target=codex, method=oneliner - 2026-08-01 15:01:28

- Scratch folder: `C:\Users\carlo\AppData\Local\Temp\my-aisy-toolkit-verify\codex-oneliner`
- Blocking for the Phase 1 gate: no (Codex CLI, best-effort per ADR-002/FR-007)

| Category | Catalog source | Installed path | Source present | Installed present | Match | Status | Note |
|---|---|---|---|---|---|---|---|
| commands | `ai-toolkit/default/commands/constitution.md` | `codex-oneliner\.codex\skills\constitution\SKILL.md` | yes | yes | no | MISMATCH | Expected: Codex translation rewrites the frontmatter, so the hash legitimately differs from the Claude Code source (best-effort, ADR-002). |
| commands | `ai-toolkit/default/commands/product-spec.md` | `codex-oneliner\.codex\skills\product-spec\SKILL.md` | yes | yes | no | MISMATCH | Expected: Codex translation rewrites the frontmatter, so the hash legitimately differs from the Claude Code source (best-effort, ADR-002). |
| commands | `ai-toolkit/default/commands/tech-spec.md` | `codex-oneliner\.codex\skills\tech-spec\SKILL.md` | yes | yes | no | MISMATCH | Expected: Codex translation rewrites the frontmatter, so the hash legitimately differs from the Claude Code source (best-effort, ADR-002). |
| commands | `ai-toolkit/default/commands/roadmap.md` | `codex-oneliner\.codex\skills\roadmap\SKILL.md` | yes | yes | no | MISMATCH | Expected: Codex translation rewrites the frontmatter, so the hash legitimately differs from the Claude Code source (best-effort, ADR-002). |
| commands | `ai-toolkit/default/commands/get-issues.md` | `codex-oneliner\.codex\skills\get-issues\SKILL.md` | yes | yes | no | MISMATCH | Expected: Codex translation rewrites the frontmatter, so the hash legitimately differs from the Claude Code source (best-effort, ADR-002). |
| commands | `ai-toolkit/default/commands/new-issue.md` | `codex-oneliner\.codex\skills\new-issue\SKILL.md` | yes | yes | no | MISMATCH | Expected: Codex translation rewrites the frontmatter, so the hash legitimately differs from the Claude Code source (best-effort, ADR-002). |
| commands | `ai-toolkit/default/commands/specify-feature.md` | `codex-oneliner\.codex\skills\specify-feature\SKILL.md` | yes | yes | no | MISMATCH | Expected: Codex translation rewrites the frontmatter, so the hash legitimately differs from the Claude Code source (best-effort, ADR-002). |
| commands | `ai-toolkit/default/commands/clarify-feature.md` | `codex-oneliner\.codex\skills\clarify-feature\SKILL.md` | yes | yes | no | MISMATCH | Expected: Codex translation rewrites the frontmatter, so the hash legitimately differs from the Claude Code source (best-effort, ADR-002). |
| commands | `ai-toolkit/default/commands/grill-me.md` | `codex-oneliner\.codex\skills\grill-me\SKILL.md` | yes | yes | no | MISMATCH | Expected: Codex translation rewrites the frontmatter, so the hash legitimately differs from the Claude Code source (best-effort, ADR-002). |
| commands | `ai-toolkit/default/commands/plan-feature.md` | `codex-oneliner\.codex\skills\plan-feature\SKILL.md` | yes | yes | no | MISMATCH | Expected: Codex translation rewrites the frontmatter, so the hash legitimately differs from the Claude Code source (best-effort, ADR-002). |
| commands | `ai-toolkit/default/commands/implement-feature.md` | `codex-oneliner\.codex\skills\implement-feature\SKILL.md` | yes | yes | no | MISMATCH | Expected: Codex translation rewrites the frontmatter, so the hash legitimately differs from the Claude Code source (best-effort, ADR-002). |
| commands | `ai-toolkit/default/commands/clean-feature.md` | `codex-oneliner\.codex\skills\clean-feature\SKILL.md` | yes | yes | no | MISMATCH | Expected: Codex translation rewrites the frontmatter, so the hash legitimately differs from the Claude Code source (best-effort, ADR-002). |
| agents | `ai-toolkit/default/agents/architect.md` | `n/a` | yes | no | no | NOT_APPLICABLE | Codex CLI has no subagent equivalent (setup-ai.md Step 5 / ADR-002) - not installed for this target by design, not a failure. |
| agents | `ai-toolkit/default/agents/code-developer.md` | `n/a` | yes | no | no | NOT_APPLICABLE | Codex CLI has no subagent equivalent (setup-ai.md Step 5 / ADR-002) - not installed for this target by design, not a failure. |
| agents | `ai-toolkit/default/agents/test-developer.md` | `n/a` | yes | no | no | NOT_APPLICABLE | Codex CLI has no subagent equivalent (setup-ai.md Step 5 / ADR-002) - not installed for this target by design, not a failure. |
| agents | `ai-toolkit/default/agents/tester.md` | `n/a` | yes | no | no | NOT_APPLICABLE | Codex CLI has no subagent equivalent (setup-ai.md Step 5 / ADR-002) - not installed for this target by design, not a failure. |
| agents | `ai-toolkit/default/agents/ui-developer.md` | `n/a` | yes | no | no | NOT_APPLICABLE | Codex CLI has no subagent equivalent (setup-ai.md Step 5 / ADR-002) - not installed for this target by design, not a failure. |
| agents | `ai-toolkit/default/agents/judge.md` | `n/a` | yes | no | no | NOT_APPLICABLE | Codex CLI has no subagent equivalent (setup-ai.md Step 5 / ADR-002) - not installed for this target by design, not a failure. |

**Result: FAIL** - 0/18 files present and byte-for-byte identical to their ai-toolkit/default/ source (6 not applicable to this target, 12 failing/mismatched).

