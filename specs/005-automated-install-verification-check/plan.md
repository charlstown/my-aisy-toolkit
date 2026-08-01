# Plan: Automated install verification check

> [!abstract] Metadata
> | | |
> |---|---|
> | **Status** | 🟡 Draft |
> | **Feature branch** | `005-automated-install-verification-check` |
> | **Requirements** | [[requirements]] |
> | **Depends on** | F1.2 `catalog.yaml` (`specs/002-catalog-yaml-manifest/`) · F1.3 `setup-ai.md` (`specs/003-setup-ai-installer/`) |

## 🧭 Scope note

This plan can be written now, but **Batches 2–5 cannot run for real** until `catalog.yaml` (002) and `setup-ai.md` (003) exist and are stable on the branch being verified — there is nothing to install or verify without them. Batch 1 (building the script) has no such dependency and can start immediately; the script should be written against the *documented shape* of `catalog.yaml` and `ai-toolkit/default/` described in `tech-spec.md`, then adjusted once 002/003 land if their real shape differs.

## 📐 Implementation decisions (resolved, not left open)

These were explicitly authorized by the user as decisions this plan should make rather than escalate:

1. **What runs the check**: a single PowerShell script, `scripts/verify-install-temp.ps1` at the repo root. PowerShell is the primary shell of the target environment (Windows), requires no extra runtime/package install, and matches the "zero dependencies" spirit of the product even though this script itself is not shipped. It is explicitly named `*-temp` to make its throwaway nature visible in the repo while it exists.
2. **Source of truth for "install"**: the script reads `catalog.yaml` and the files under `ai-toolkit/default/` directly from the local working tree (not over HTTPS from `raw.githubusercontent.com`). This mirrors exactly what `setup-ai.md`'s fetch step would return once pushed, without the flakiness/rate-limit risk of hitting GitHub repeatedly for one-off local verification. This is a deliberate scope reduction of the check: it proves *file parity*, not *network fetch correctness*.
3. **Dummy/scratch folder location**: the script creates fresh directories under the OS temp path (`$env:TEMP\my-aisy-toolkit-verify\<target>-<method>\`), never inside the repo. Each run starts from a deleted/recreated folder, so "target folder not empty / prior install reused" (an edge case in requirements.md) is a non-issue by construction — every run is a clean install.
4. **How "one-liner" vs "copy-paste" are exercised**: per ADR-001 in `tech-spec.md`, both install methods are the same underlying mechanism (an agent reads `setup-ai.md`, fetches the manifest, fetches each file, writes it) — they differ only in how a human/agent *kicks off* the read of `setup-ai.md`, not in what gets written. The script models this honestly: it exposes a `-Method oneliner|copypaste` parameter that drives the *same* core install routine into two independently named scratch folders, so FR-002 ("both install methods") is evidenced as two separate, independently-verified runs. This is recorded here as an explicit decision, not silently invented: if a future change to `setup-ai.md` ever makes the two methods diverge technically, this script's assumption becomes false and must be revisited.
5. **Codex CLI translation**: the script implements the minimal `SKILL.md` + YAML-frontmatter translation described in ADR-002/tech-spec.md (folder-per-skill under `.codex/skills/<name>/SKILL.md`) as best-effort. Its result (pass, partial, or fail) is documented regardless of outcome — a failure here is expected to be plausible and is explicitly non-blocking (FR-007).
6. **Output/report format**: a single markdown file, `specs/005-automated-install-verification-check/evidence.md`, generated/appended by the script and reviewed by hand. It contains one section per (target, method) run with a file-by-file pass/fail table plus an aggregate pass/fail line. Unlike the script itself, **this evidence file is not deleted** — it is the permanent record that the Phase 1 gate was met (SC-004).
7. **Comparison rule**: byte-for-byte comparison (`Get-FileHash` or raw byte comparison) between each installed file and its declared source under `ai-toolkit/default/`, per FR-004 (already resolved in requirements.md).

## ✅ Tasks

## Batch 1 — Build the verification script

- [x] @test-developer · Build `scripts/verify-install-temp.ps1`: implement a PowerShell script (temporary, repo-root, per decision #1) that: (a) parses `catalog.yaml`'s `profiles.default.commands` / `profiles.default.agents` lists and their source paths; (b) exposes parameters `-Target claude|codex`, `-Method oneliner|copypaste`, and `-ScratchRoot` (defaulting to `$env:TEMP\my-aisy-toolkit-verify`); (c) for `-Target claude`, copies each catalog-declared source file from `ai-toolkit/default/commands/` and `ai-toolkit/default/agents/` into `<scratch>/<target>-<method>/.claude/commands/` and `.../.claude/agents/` respectively, matching Claude Code's native layout; (d) for `-Target codex`, additionally translates each file into `.codex/skills/<name>/SKILL.md` per the ADR-002 shape described in `tech-spec.md`; (e) after writing, walks every catalog-declared file and does a byte-for-byte comparison (`Get-FileHash`) between the installed copy and its `ai-toolkit/default/` source, recording present/missing and match/mismatch per file; (f) appends a run section to `specs/005-automated-install-verification-check/evidence.md` with a per-file table and a pass/fail aggregate line for that (target, method) combination; (g) exits non-zero if any file fails for `-Target claude` (blocking), but always exits zero for `-Target codex` regardless of result (non-blocking, FR-007). Do not implement any bash/curl one-liner invocation or real HTTP fetch — this script performs the equivalent local file operations per decision #2.

## Batch 2 — Verify Claude Code installs (blocking, required for the gate)

- [x] @tester · Confirm prerequisites before running: verify that `catalog.yaml` (specs/002) and `setup-ai.md` (specs/003) exist at the repo root on the branch under test and declare the `default` profile's commands/agents lists. If either is missing or the `default` profile isn't declared yet, stop and report this batch as blocked-on-dependency (not a script failure) — do not proceed to install runs until both exist.
- [x] @tester · Run the one-liner install verification against Claude Code: execute `scripts/verify-install-temp.ps1 -Target claude -Method oneliner`, capture full console output, confirm every file declared in `catalog.yaml` for the `default` profile is present and byte-for-byte identical to its `ai-toolkit/default/` source, and confirm the run appended a passing section to `evidence.md`. If any file is missing or mismatched, report it as a blocking failure with the exact file(s) and diff details (do not silently retry or patch the catalog/installer — that belongs to 002/003, report back instead).
- [x] @tester · Run the copy-paste install verification against Claude Code: execute `scripts/verify-install-temp.ps1 -Target claude -Method copypaste`, capture output, and confirm the same file-parity result as the one-liner run. If the two methods' results differ for the same file set, flag this explicitly (per the requirements.md edge case) since under decision #4 they are expected to be identical — a divergence indicates a bug in the script's shared install routine, not a real difference between install methods.

## Batch 3 — Verify Codex CLI (best-effort, non-blocking)

- [x] @tester · Run the install verification against Codex CLI at least once: execute `scripts/verify-install-temp.ps1 -Target codex -Method oneliner`, capture output, and record the pass/fail result in `evidence.md` regardless of outcome (FR-005/FR-006). Explicitly note in the evidence that this result does not block the Phase 1 gate (ADR-002, best-effort).

## Batch 4 — Confirm gate evidence and close out

- [x] @judge · Review the verification evidence against the Phase 1 gate criteria: read `specs/005-automated-install-verification-check/evidence.md`, `specs/roadmap.md`'s Gate Final Milestone, and this feature's `requirements.md` (SC-001–SC-005). Confirm: both Claude Code runs (one-liner, copy-paste) show every catalog-declared `default`-profile file present and byte-for-byte matching its source (blocking — must be PASS); the Codex CLI run was attempted at least once and its result is documented (any outcome acceptable); and the evidence file is complete enough to stand as the permanent gate record after the script is deleted. Emit PASS or CHANGES_REQUESTED; if CHANGES_REQUESTED, hand back the specific missing/failing evidence to @tester (re-run) or @test-developer (fix script bug) as appropriate — do not proceed to deletion until PASS.
- [x] @tester · Delete the temporary verification script and confirm SC-005: after the judge's PASS, remove `scripts/verify-install-temp.ps1` (and its now-empty `scripts/` folder if nothing else lives there) from the repository, leaving `specs/005-automated-install-verification-check/evidence.md` in place as the permanent record. Confirm via `git status`/directory listing that the script no longer exists in the working tree, satisfying SC-005 ("its own presence or absence is itself verifiable").

### Critical Files for Implementation
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\catalog.yaml (to be created by 002 — the manifest the script parses)
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\setup-ai.md (to be created by 003 — defines the two install methods the script must mirror)
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\ai-toolkit\default\ (commands/ and agents/ — the source-of-truth files the script compares against, from 001)
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\scripts\verify-install-temp.ps1 (new, temporary — the deliverable of Batch 1, deleted in Batch 4)
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\specs\005-automated-install-verification-check\evidence.md (new, permanent — the gate evidence record)
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\specs\tech-spec.md (ADR-001/ADR-002/ADR-003/ADR-005 — governs the script's design decisions above)
