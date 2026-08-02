# Plan — Add optional "Utils" skill pack (digest, grill-me, for-dummies) to setup-ai's install flow

Feature Branch: `002-add-optional-utils-skill-pack-digest-grill-me-for`

Requirements: `specs/002-add-optional-utils-skill-pack-digest-grill-me-for/requirements.md`

Created: 2026-08-02

## 1. Context found (verified in the repo)

| Finding | Evidence |
|---|---|
| `catalog.yaml` today only has `profiles.<profile>.{commands,agents}` — flat lists of source paths. No `packs` key exists. | `catalog.yaml` |
| `setup-ai.md` Step 1 states the agent + profile questions word-for-word, but the profile question is actually *triggered* in Step 2, once the catalog is fetched and the profile count is known ("This is the point where you find out how many profiles the catalog declares... go back and ask it now") | `setup-ai.md` L80-93, L116-119 |
| Step 3 fetches every file in `profiles.<profile>.commands`/`agents`, with per-file retry-once-then-skip resilience | `setup-ai.md` L129-152 |
| Step 4 (Claude Code) and Step 5 (Codex CLI) map source path → destination unprefixed: `ai-toolkit/default/commands/<name>.md → .claude/commands/<name>.md` / `.codex/skills/<name>/SKILL.md` (Step 5 translates, Step 4 copies byte-for-byte) | `setup-ai.md` L154-226 |
| Wrap-up already has a precedent for a distinct extra section outside Installed/Updated/Skipped: "Global launcher", shown only when there's something to say | `setup-ai.md` L447-521 |
| `.claude/commands/digest.md` already exists in this repo, added standalone (commit `3fa11eb`), **never** part of `ai-toolkit/` or `catalog.yaml`. Its Spanish description already matches the behavior FR-004's English one-liner summarizes. | `.claude/commands/digest.md` |
| `grill-me.md` existed at `ai-toolkit/default/commands/grill-me.md` and `.claude/commands/grill-me.md` until PR #23 removed it from the default profile (commit `58242a6`, merge `1930aa8`). Its original English `description` is byte-identical to FR-004's grill-me one-liner. Full content is recoverable via `git show 58242a6~1:ai-toolkit/default/commands/grill-me.md`. | `git log --all -- "**/grill-me.md"` |
| `for-dummies` does not exist anywhere in the repo or its history — must be authored from scratch. | `find`/`grep` across the repo |
| Every skill file in `ai-toolkit/default/commands/*.md` follows the same shape: YAML frontmatter (`description`, sometimes `name`) + `## Language` boilerplate + numbered `## Step N` sections. | `ai-toolkit/default/README.md` |
| No automated tooling verifies skill markdown files; the documented testing strategy is manual diff + logical trace of Acceptance Scenarios against the final text. | `specs/tech-spec.md` § Testing Strategy; precedent in `specs/006-constitution-chain-roadmap/plan.md`, `specs/fix-setup-ai-step-6-global-launcher-offer/plan.md` |

**Scope conclusion:** effective changes touch `catalog.yaml`, three new files under `ai-toolkit/utils/commands/`, and `setup-ai.md` (Step 1, Step 2, Step 3, Step 4, Step 5, Wrap-up). `specs/product-spec.md`, `specs/tech-spec.md`, `README.md`, `README-ES.md`, and `CHANGELOG.md` are out of scope for this plan — realigning them is `/clean-feature`'s job once this plan is fully implemented (same precedent set by prior plans in this repo).

## 2. Decisions

### D-01 — `packs.utils` is a flat list of bare skill names, not source paths

`catalog.yaml` gains a top-level `packs:` key; `packs.utils` is `[digest, grill-me, for-dummies]` — bare names, exactly as FR-001's example shows. `setup-ai.md` resolves each name to a source path by a fixed convention (D-02), not by listing full paths in the catalog. Rejected alternative: making `packs.utils` a list of source paths like `profiles.<profile>.commands` — rejected because FR-001's example is explicitly bare names, and a fixed one-folder convention is simpler for a pack that will only ever contain commands.

### D-02 — New source folder `ai-toolkit/utils/commands/`, sibling to `ai-toolkit/default/`

`digest.md`, `grill-me.md`, `for-dummies.md` live at `ai-toolkit/utils/commands/<name>.md` — same two-level shape (`<pack>/commands/<name>.md`) as `ai-toolkit/default/commands/`. Name → path convention: `ai-toolkit/utils/commands/<name>.md`.

### D-03 — Utils question is triggered where the profile question already is: Step 2, right after the profile is resolved; documented under Step 1 per FR-003's literal ordering

Reuse the existing deferred-question pattern already used for the profile question. Step 1 gains the question's literal text plus the "only if the catalog declares `packs.utils`" gating note. Step 2 gains: once the profile is resolved, check whether the fetched catalog declares `packs.utils` — if so, go back and ask the Utils question now, listing every util with its FR-004 description, numbered, under a "Utils" header; if the key is absent, skip silently, no error, no warning. Rejected alternative: asking Utils strictly inside Step 1's own body before ever fetching the catalog — rejected because Step 1 cannot know whether `packs.utils` exists until after the Step 2 fetch, the same constraint that already forced the profile question into this "documented in Step 1, triggered in Step 2" shape.

### D-04 — Reply-parsing rule: any invalid number anywhere in the reply zeroes out the whole answer

Split the reply on commas; accept "all" case-insensitively; treat as unclear (⇒ zero utils installed, non-blocking, never repeated) whenever the reply is blank, contains a non-numeric token, or contains any number outside `1..N` (N = number of utils listed) — even if other numbers in the same reply are valid (FR-005, Edge Cases).

### D-05 — `aisy.` prefix applies only to the Utils mapping addition in Step 4/Step 5; the existing profile mapping stays unprefixed

Step 4 and Step 5 each gain one additive mapping rule: `ai-toolkit/utils/commands/<name>.md → .claude/commands/aisy.<name>.md` and `ai-toolkit/utils/commands/<name>.md → .codex/skills/aisy.<name>/SKILL.md` (translated per Step 5's existing rules). The pre-existing `ai-toolkit/default/commands/<name>.md → .claude/commands/<name>.md` rule is untouched — profile files never get the `aisy.` prefix, only Utils files do (FR-006).

### D-06 — Wrap-up gains a "Utils" section, modeled on the existing "Global launcher" section's separateness

Add a "Utils" block to the Wrap-up listing only the selected-and-written util files, shown whenever at least one util was installed and omitted otherwise — same "only show if there's something to say" discipline the Global launcher section already uses. Never folded into the core "Installed" list (FR-008).

### D-07 — `for-dummies.md` structure is locked by the architect before authoring

Because for-dummies' behavior (FR-010–FR-010f) is more elaborate than a reused one-liner, Batch 0 includes a dedicated architect sub-task researching comparable structures — `digest.md`'s interrogate-then-research-then-synthesize shape and `grill-me.md`'s rounds-of-questions shape as in-repo precedent, plus a short web check for teaching/concept-explainer patterns — and handing @code-developer a locked Step-by-step outline plus the exact `AskUserQuestion` wording for the ">3 concepts detected" case, so the file is authored once, correctly.

### D-08 — Root docs are out of scope for this plan

`README.md`, `README-ES.md`, `CHANGELOG.md`, `specs/product-spec.md`, `specs/tech-spec.md` are not touched here; no FR/SC requires them, and `/clean-feature` is this repo's dedicated mechanism for realigning root docs/specs once a feature's plan is fully merged.

## 3. Plan by batches

### Batch 0 — Lock down exact schema, wording, and for-dummies structure

- [x] @architect · Lock catalog.yaml and setup-ai.md literal text: produce, ready to paste, (a) the exact `packs: / utils:` YAML block per D-01/D-02; (b) the exact Utils question wording for Step 1/2 per D-03 — "Utils" header, numbered list of `digest`/`grill-me`/`for-dummies`, each with its FR-004 one-liner verbatim, plus the "ask only if `packs.utils` is declared" gating sentence; (c) the exact reply-parsing rule text per D-04; (d) the exact Step 3 fetch-list extension sentence so selected utils' resolved source paths join the profile's fetch list; (e) the exact Step 4 and Step 5 additive mapping rules per D-05 for both Claude Code and Codex CLI destinations; (f) the exact Wrap-up "Utils" section wording and placement per D-06. Document the exact insertion points (line ranges) in the current `setup-ai.md` for each of (b)-(f).
- [x] @architect · Research and lock the `for-dummies.md` structure per D-07: read `.claude/commands/digest.md` and the restored `grill-me.md` (via `git show 58242a6~1:ai-toolkit/default/commands/grill-me.md`) for in-repo structural precedent, do a short web check for comparable teaching/concept-explainer skill or prompt patterns, then produce a locked Step-by-step outline for `ai-toolkit/utils/commands/for-dummies.md` covering: input capture (concept/idea/link/document, FR-010), internal concept identification, the >3-concepts branch with the exact `AskUserQuestion` wording for selecting up to 3 (FR-010b), the ≤2-named-concepts shortcut that skips asking (FR-010c), the per-concept explain-with-examples loop (FR-010a), the internet-research step prioritizing official documentation via `WebSearch`/`WebFetch` (FR-010d), the optional up-to-3-free-resources-per-concept rule with the "explanation must stand on its own" constraint (FR-010e), and the closing "go deeper" offer (FR-010f). Include the skill's own English frontmatter `description` aligned with FR-004's for-dummies one-liner, and confirm it follows the `## Language` + numbered `## Step N` convention documented in `ai-toolkit/default/README.md`.

### Batch 1 — Catalog and Utils pack content

- [x] @code-developer · Edit `catalog.yaml`: add the `packs.utils` block exactly as locked in Batch 0 (D-01), leaving the existing `profiles` key untouched (FR-001, SC-001).
- [x] @code-developer · Add `ai-toolkit/utils/commands/digest.md`: port the existing `.claude/commands/digest.md` content byte-for-byte into the new source-of-truth location (D-02), no behavioral changes — this becomes the canonical file `setup-ai.md` fetches from (FR-009, SC-006).
- [x] @code-developer · Add `ai-toolkit/utils/commands/grill-me.md`: restore the file exactly as it existed before removal (`git show 58242a6~1:ai-toolkit/default/commands/grill-me.md`) into the new `ai-toolkit/utils/commands/` location (D-02), unchanged content — this becomes the canonical file `setup-ai.md` fetches from (FR-009, SC-006).
- [x] @code-developer · Author `ai-toolkit/utils/commands/for-dummies.md` from scratch, following the outline locked in Batch 0's second task exactly: frontmatter (`description` in English per FR-004/D-07), `## Language` section matching every other skill in `ai-toolkit/default/commands/*.md`, and numbered steps implementing FR-010 through FR-010f in full.

### Batch 2 — Wire the Utils question and installation into setup-ai.md

- [x] @code-developer · Edit `setup-ai.md` Step 1: insert the Utils question text locked in Batch 0 ("Utils" header, numbered `digest`/`grill-me`/`for-dummies` with their FR-004 descriptions, reply-by-numbers/"all"/blank), placed after the existing profile question, noting it is gated on `packs.utils` and actually triggered in Step 2 (FR-002, FR-003, SC-002).
- [x] @code-developer · Edit `setup-ai.md` Step 2: after the profile is resolved, add the detection logic locked in Batch 0 — check whether the fetched catalog declares `packs.utils`; if so, ask the Utils question now and apply the exact reply-parsing rule from D-04 (comma-separated numbers / "all" / blank / any invalid number ⇒ zero utils, non-blocking, asked at most once); if `packs.utils` is absent, skip silently with no error or warning (Edge Cases, FR-003, FR-005, FR-007, SC-004).
- [x] @code-developer · Edit `setup-ai.md` Step 3: extend the fetch-list description with the sentence locked in Batch 0 so every selected util's resolved source path (`ai-toolkit/utils/commands/<name>.md`) is fetched alongside the profile's `commands`/`agents`, reusing the existing per-file retry-once-then-skip resilience.
- [x] @code-developer · Edit `setup-ai.md` Step 4 (Claude Code): add the additive `aisy.` prefix mapping rule from D-05 for Utils files, leaving the existing profile mapping rule unmodified (FR-006, SC-003).
- [x] @code-developer · Edit `setup-ai.md` Step 5 (Codex CLI): add the additive `aisy.` prefix mapping rule from D-05 for Utils files, translated per Step 5's existing rules, leaving the existing profile mapping rule unmodified (FR-006, SC-003).
- [x] @code-developer · Edit `setup-ai.md` Wrap-up: add the "Utils" section locked in Batch 0 (D-06) — distinct from Installed/Updated/Skipped, shown only when at least one util was selected and installed, listing exactly the util files written (FR-008, SC-005).

### Batch 3 — Verification

- [ ] @tester · Verify User Story 1 end-to-end by tracing the final `setup-ai.md` text against every Acceptance Scenario and Edge Case: grouped-checklist question shape/position/content; a "1,3" reply resolving only `digest`/`for-dummies` to `aisy.*` at correct Claude Code and Codex CLI destinations; an "all" reply resolving all three; a blank reply and a "1,9" mixed valid/invalid reply both resulting in zero utils with no error and no repeated question; and no Utils question at all when `packs.utils` is absent. Report any wording gap with exact `setup-ai.md` line numbers, returning to Batch 2 if found.
- [ ] @tester · Verify User Story 2 by tracing the Wrap-up text: confirm the "Utils" section is distinct from the core "Installed" section, appears only when at least one util was installed, and lists exactly the installed util skill files (FR-008, SC-005).
- [ ] @tester · Verify catalog and source content: confirm `catalog.yaml`'s `packs.utils` list matches the three filenames actually present at `ai-toolkit/utils/commands/`, that `digest.md` and `grill-me.md` content is unchanged from their prior versions (diff against `.claude/commands/digest.md` and against `git show 58242a6~1:ai-toolkit/default/commands/grill-me.md`), and that `for-dummies.md`'s frontmatter `description` matches the FR-004 one-liner (SC-001, SC-006).
- [ ] @tester · Verify `for-dummies.md` behavior by tracing its own instructions against FR-010–FR-010f: the ≤3-concepts cap and its exact selection question, the ≤2-named-concepts shortcut, the per-concept explain-with-examples requirement, the internet-research step prioritizing official documentation, the "up to 3 optional resources, explanation must stand alone" rule, and the closing go-deeper offer. Report any gap with exact line references, returning to Batch 1 if found.

### Batch 4 — Quality gate

- [ ] @judge · Review the complete diff (`catalog.yaml`, `ai-toolkit/utils/commands/digest.md`, `ai-toolkit/utils/commands/grill-me.md`, `ai-toolkit/utils/commands/for-dummies.md`, `setup-ai.md`) against `specs/002-add-optional-utils-skill-pack-digest-grill-me-for/requirements.md`: confirm every FR-001 through FR-011 (including FR-010a–FR-010f) and every SC-001 through SC-006 is satisfied; confirm the `aisy.` prefix applies only to Utils files and never to profile files; confirm the Utils question is non-blocking and never repeats on an unclear reply; confirm no root docs (`README.md`, `README-ES.md`, `CHANGELOG.md`, `specs/product-spec.md`, `specs/tech-spec.md`) were touched (D-08, out of scope). Emit PASS or CHANGES_REQUESTED with exact file and line for each finding; if CHANGES_REQUESTED, return to the relevant Batch 1/2 task.

### Critical Files for Implementation
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\catalog.yaml
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\setup-ai.md
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\.claude\commands\digest.md
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\ai-toolkit\default\commands\grill-me.md (recoverable via `git show 58242a6~1:ai-toolkit/default/commands/grill-me.md`)
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\ai-toolkit\default\README.md
