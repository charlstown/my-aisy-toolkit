# ai-toolkit/default — Skill & Agent Catalog

This folder is the canonical source of the `default` profile: every file under `commands/` and `agents/` here is what `setup-ai` fetches and writes into a target repo's `.claude/commands/` / `.claude/agents/` (or translates into `.codex/skills/` for Codex CLI, best-effort). The manifest that declares exactly which files belong to this profile is [`catalog.yaml`](../../catalog.yaml) at the repo root.

This document is internal technical reference, not part of the distributed catalog — `setup-ai` never fetches it. It exists to explain, file by file, what each skill and agent actually does.

## Structure

```
ai-toolkit/default/
├── commands/    # 11 skills (Claude Code's native "slash command" shape)
│   └── *.md
└── agents/      # 6 subagents (Claude Code subagent shape)
    └── *.md
```

Every file is self-documented: a skill is a Markdown file with YAML frontmatter (`description`, sometimes `name`) followed by a body of numbered instructions for an AI agent to follow. An agent file adds `tools` and `model` to the frontmatter, and its body describes a role/persona rather than a numbered procedure. There is no shared template or include mechanism between files — the `## Language` boilerplate at the top of every skill is intentionally duplicated verbatim rather than referenced.

> [!note] Codex CLI
> Codex CLI has no native equivalent to subagents. In best-effort mode, `setup-ai` only translates the **skills** catalog into `.codex/skills/*/SKILL.md`; the `agents/` folder is Claude-Code-only.

---

## Skills (`commands/`)

Nine of the eleven skills form one closed sequential workflow, each ending by suggesting the next one. The remaining two (`new-issue`, `grill-me`) are standalone utilities invoked on demand that never show a next-step suggestion.

### The sequential workflow

| # | Skill | Produces | Suggests next |
|---|---|---|---|
| 1 | `/constitution` | `specs/product-spec.md` + `specs/tech-spec.md` (runs both skills below, in that order) | `/roadmap` *(optional)* · `/specify-feature` |
| 2 | `/product-spec` | `specs/product-spec.md` | `/tech-spec` |
| 3 | `/tech-spec` | `specs/tech-spec.md` | `/roadmap` *(optional)* · `/specify-feature` |
| 4 | `/roadmap` | `specs/roadmap.md` | `/specify-feature` |
| 5 | `/specify-feature` | one `specs/{NNN}-{slug}/requirements.md` per detected feature | `/clarify-feature` *(optional)* · `/plan-feature` |
| 6 | `/clarify-feature` | closes the `DEFINITION GAP` section of a `requirements.md` | `/plan-feature` |
| 7 | `/plan-feature` | `specs/{NNN}-{slug}/plan.md` | `/implement-feature` |
| 8 | `/implement-feature` | implemented code, an open PR, `plan.md` marked `[x]` / `[blocked]` | `/clean-feature` |
| 9 | `/clean-feature` | aligned root specs, a closed issue, the `specs/{NNN}-{slug}/` folder deleted | *(none, end of the loop)* |

> [!tip] Optional branches
> `/roadmap` and `/clarify-feature` are presented as skippable, not mandatory: a small project can go straight from the constitution to `/specify-feature`, and a self-contained `requirements.md` can go straight to `/plan-feature` without a clarification round.

### Standalone skills

| Skill | Produces | Notes |
|---|---|---|
| `/new-issue` | a GitHub issue (`gh issue create`) | Auto-detects bug vs. feature; the bug flow investigates the code and reproduces the failure in-browser before drafting the issue |
| `/grill-me` | the input document rewritten in place (or printed) with its gaps closed | Generic — works on any document, not only specs; the user picks 4, 6, or 12 questions of depth |

---

### `/constitution`

**File:** `commands/constitution.md`
**Trigger phrases:** "constitution", "constitución", "funda el proyecto", "bootstrap specs", "crea la constitución del proyecto"

A thin orchestrator, not an interview of its own. It checks whether `specs/product-spec.md` and `specs/tech-spec.md` already exist, then runs `/product-spec` to completion and `/tech-spec` to completion, strictly in that order — `/tech-spec`'s own Phase 0 reads the freshly written `product-spec.md`, so running them in parallel would defeat the point.

- **Reads:** presence of `specs/product-spec.md` / `specs/tech-spec.md`
- **Writes:** nothing directly — delegates the writing to the two skills it runs
- If either file already exists, it asks whether to regenerate both, only run what's missing, or cancel.

### `/product-spec`

**File:** `commands/product-spec.md`
**Trigger phrases:** "product spec", "create productspec", "genera productspec"

Interviews the user with exactly 3 questions in one `AskUserQuestion` call (scope, decisions, context) and writes `specs/product-spec.md` following the PSPEC template: Metadata · Vision · Problem Statement · Target User · Design Principles · Architecture · Interfaces · Configuration · Operations · Deliverables · Project Structure · Out of Scope · Future · Discovery.

- **Reads:** any existing `product-spec.md` / `tech-spec.md` / `roadmap.md`, `README.md`, the dependency manifest
- **Writes:** `specs/product-spec.md` (single file, no sub-files)
- Its own next-step block is suppressed when it runs as Step 1 of `/constitution`, so a constitution run prints one closing block, not three.

### `/tech-spec`

**File:** `commands/tech-spec.md`
**Trigger phrases:** "tech spec", "genera techspec", "create tech spec"

A fully conversational, round-based interview covering six categories (scope, stack, architecture, data, operations, decisions). The user picks a total question budget (5 quick / 8 balanced / 12 exhaustive) up front, distributed across the six rounds by where the biggest gaps are. Writes `specs/tech-spec.md` following the TSPEC template, including Mermaid diagrams, ADRs, and a Known Limitations section.

- **Reads:** any existing `tech-spec.md` / `product-spec.md` / `roadmap.md`, the dependency manifest, DB schema, CI/deploy config, the source tree
- **Writes:** `specs/tech-spec.md`
- Same `/constitution`-suppression rule as `/product-spec`.

> [!warning] One question at a time
> `/tech-spec` enforces a strict rule: **one `AskUserQuestion` call per turn**, nothing else in that turn, and it must wait for the real answer before asking the next question. It never batches questions or guesses ahead. `/roadmap` follows the same rule for its own 3-question interview.

### `/roadmap`

**File:** `commands/roadmap.md`
**Trigger phrases:** "roadmap", "genera roadmap", "create roadmap", "planifica el roadmap"

Translates the ProductSpec (what) and TechSpec (how) into an ordered execution plan: phases, dependencies, and closing gates. Detects whether the TechSpec has a Proof-of-Concepts section with explicit hypotheses — if so, adds a Phase 0 for them before the feature phases. A 3-question interview (phase structure, issue tracking system, gate criterion) drives the write.

- **Reads:** `specs/product-spec.md`, `specs/tech-spec.md`, any existing `specs/roadmap.md`, `README.md`
- **Writes:** `specs/roadmap.md`
- Never invents features or PoCs: every entry must trace back to something already in the two root specs.

### `/specify-feature`

**File:** `commands/specify-feature.md`
**Trigger phrases:** "specify-feature", "especifica", "define los requirements"

Turns one or several already-existing feature descriptions — a file, a URL, a GitHub issue, a `roadmap.md` row, or a raw prompt — into `requirements.md` specs. Detects the source automatically (explicit input → `roadmap.md` → open GitHub issues → ask the user, in that priority order), lets the user pick which candidates to develop, then dispatches **one subagent per feature in parallel** to fill the spec-kit-style template.

- **Reads:** the input source (file/URL/issue/roadmap), existing `specs/*` folders (to avoid number collisions)
- **Writes:** `specs/{NNN}-{slug}/requirements.md` per selected feature
- Never resolves ambiguity itself — every open question goes into a `## DEFINITION GAP` section instead of being guessed at. This is the key difference from `/grill-me`.

### `/clarify-feature`

**File:** `commands/clarify-feature.md`
**Trigger phrases:** "clarify-feature", "clarifica", "cierra los gaps", "resuelve los gaps"

The counterpart to `/specify-feature`: it interrogates the user about the exact items already listed under a `requirements.md`'s gap heading, folds each decision back into the document, and deletes the gap section once nothing is left open. It only works gaps that are already itemized — finding *new* gaps is `/grill-me`'s job.

- **Reads:** one or more `specs/*/requirements.md` with an open `## DEFINITION GAP` (or equivalent) heading
- **Writes:** the same `requirements.md`, edited in place
- Always sequential — never dispatches parallel subagents, since it needs the user's live answers feature by feature. Every question offers an explicit "not sure yet" option, which leaves that gap open on purpose.

### `/plan-feature`

**File:** `commands/plan-feature.md`
**Trigger phrases:** "plan-feature", "genera el plan", "planifica esta feature", "crea el plan.md"

Given a `requirements.md`, asks up to 3 critical clarifying questions only if something would block writing a concrete task (not for anything the planner could infer from the code), discovers the target repo's own `.claude/agents/*.md` catalog, and invokes a `planner` subagent to generate `plan.md` with each task attributed to the best-fitting `@agent-name`.

- **Reads:** the selected `requirements.md`, the target repo's `.claude/agents/*.md` (if any)
- **Writes:** `specs/{NNN}-{slug}/plan.md`
- If the repo defines no subagents, tasks are written without an `@agent` tag.

### `/implement-feature`

**File:** `commands/implement-feature.md`
**Trigger phrases:** "implement-feature", "develop plan", "ejecuta el plan", "implementa el plan", "desarrolla el plan"

The orchestrator that actually runs a plan. Every plan — even a single one — executes inside an isolated `git worktree` (`.worktrees/{slug}` on branch `{prefix}/{slug}`), never on the main working tree. Supports running several plans sequentially or in parallel (max 2 workers), and warns about cross-plan file conflicts before letting the user pick a mode. For each `- [ ]` task it dispatches one subagent, marks it `[x]` on success, retries once on failure, and marks it `[blocked]` with a reason if the retry also fails — then commits at the end of each batch.

- **Reads:** `specs/*/plan.md` with pending `- [ ]` tasks
- **Writes:** the implemented code, `plan.md` (`[x]` / `[blocked]`), a pushed branch, an opened PR
- Finalization pushes the branch, opens a PR, closes the linked issue if one is referenced, and removes the worktree.

> [!warning] `@human` tasks are never delegated
> A task tagged `@human` (a production write/migration, the merge that triggers a deploy, a go/no-go decision) is never handed to a subagent. `/implement-feature` presents the exact steps to the user and pauses for their explicit confirmation before continuing — this is a hard rule, not a fallback.

### `/clean-feature`

**File:** `commands/clean-feature.md`
**Trigger phrases:** "clean-feature", "cleanup", "limpia las carpetas", "limpia los specs", "alinea los specs"

Closes the loop. For every `specs/{NNN}-{slug}/` whose `plan.md` has no `- [ ]` left, it summarizes what changed, audits the root specs (`product-spec`, `tech-spec`, `css-spec`, `ui-spec`, `infra-spec`, `security-spec`, `roadmap` — whichever are relevant to that plan) for drift, applies the minimal edits needed to realign them, and only then — after an explicit user confirmation — deletes the feature folder and closes its linked GitHub issue with a summary comment.

- **Reads:** every `specs/*/plan.md` with zero pending tasks, the corresponding `requirements.md`, and the root specs it audits
- **Writes:** surgical edits to whichever root specs drifted, then deletes the completed `specs/{NNN}-{slug}/` folder
- Deliberately shows **no** next-step block: it is the last step of the loop.

> [!caution] Deletes folders
> Step 6 runs `Remove-Item -Recurse -Force` on every confirmed folder. The confirmation in Step 5 is the only gate before that — decline it and the specs stay updated but nothing is deleted.

---

## Agents (`agents/`)

The six agents are single-purpose roles a skill (mainly `/implement-feature`) dispatches per task, matched by name to a `@agent-name` tag in a `plan.md`.

| Agent | Role | Tools | Model |
|---|---|---|---|
| `architect` | Discovery, alternatives, and decisions — designs and decomposes a solution *before* anything gets implemented. Does not write application code. | Read, Grep, Glob, Bash, WebSearch, WebFetch, Write, Edit | opus |
| `code-developer` | Implements application code from an already-defined plan; verifies it compiles/lints but does not design the architecture. | Read, Grep, Glob, Write, Edit, Bash | sonnet |
| `test-developer` | Writes tests (unit, integration, e2e) from requirements or existing code. Does **not** run them. | Read, Grep, Glob, Write, Edit | sonnet |
| `tester` | Runs the test suite and exercises real behavior; reports and diagnoses failures. Does **not** implement fixes. | Read, Grep, Glob, Bash, Write | sonnet |
| `ui-developer` | Front-end + visual design specialist (HTML/CSS/TypeScript/React); designs and implements complete screens. | Read, Grep, Glob, Write, Edit, Bash | sonnet |
| `judge` | Independent quality gate. Reviews work already produced by the other agents and rules `PASS` or `CHANGES_REQUESTED` — never implements anything itself. | Read, Grep, Glob, Bash | opus |

> [!note] `test-developer` vs. `tester`
> The split is deliberate: `test-developer` has no `Bash` access, so it physically cannot run anything it writes; `tester` runs the suite and diagnoses failures but hands the fix back to `code-developer` or `test-developer` rather than patching production logic itself.

> [!note] Not every subagent name in the skills is one of these six
> `/plan-feature` invokes a `planner` subagent, and `/clean-feature` invokes `general-purpose` and `implementation-agent` subagents for its audit/update steps. None of those three names correspond to a file in `agents/` — those steps rely on the executing AI agent's own generic/default agent type rather than on one of the six named roles above.

---

## See also

- [`catalog.yaml`](../../catalog.yaml) — the manifest `setup-ai` actually reads to know which of these files belong to the `default` profile.
- [`specs/product-spec.md`](../../specs/product-spec.md) — the product-level catalog table (one-line "what it does" per skill/agent) and the "Keep it AIsy" tone this toolkit follows.
- [`README.md`](../../README.md) — the repo's front door: installation, quick setup, and the same catalog at a glance.
