# Plan — README as product front

Source: specs/004-readme-as-product-front/requirements.md

## Context gathered

> [!warning] Superseded by Batch 1 (2026-08-01)
> The three bullets below marked ~~struck through~~ were written before F1.1–F1.3 landed and are **stale**.
> See the Batch 1 handoff note before Batch 2 for the verified state of the repo.

- **specs/product-spec.md** — has the full Catalog section (12 skills + 6 agents with descriptions/roles) that the README must mirror, plus the "README as product" design principle and install method definitions.
- ~~**specs/tech-spec.md** — defines how `setup-ai` is supposed to work (ADR-001 through ADR-005), but confirms `setup-ai.md` and `ai-toolkit/default/` do not exist in the repo yet (only `specs/003-setup-ai-installer/requirements.md` and now its `plan.md` exist).~~ → tech-spec's ADR-001..ADR-005 still stand, but `setup-ai.md`, `catalog.yaml` and `ai-toolkit/default/` **now all exist on `main`** (F1.1–F1.3 merged).
- **README.md** (current) — is a 2-line placeholder that mentions an `agents.md` file, which is absent from both product-spec.md and tech-spec.md.
- **specs/roadmap.md** — confirms F1.4 (this feature) depends on F1.3 (setup-ai) being done first, and the Gate Final Milestone criterion that the README alone must be enough for a stranger to install cleanly.
- ~~*(missing from the original round)*~~ → **specs/ui-spec.md** (Status: 🟢 **Locked for F1.4**) — resolves FR-011..FR-014 via the `/ui-spec` design interview and is the authority on README structure, badges and catalog depth. `requirements.md`'s DEFINITION GAP block explicitly defers to it ("Superseded by that document — kept here only as a decision log").

## Batch 1 — Structural decisions & dependency check

- [x] @architect · Confirm F1.3 dependency and lock README structure: Check whether `setup-ai.md` exists at the repo root and is stable (status of spec `003-setup-ai-installer`). If it exists and is stable, use it as the source of truth for the one-liner and copy-paste install steps. If it does not yet exist or is still in draft (as of this planning round it does not exist in the repo), use `specs/product-spec.md` §Interfaces (Installation) and `specs/tech-spec.md` §Module Design / ADR-001..ADR-005 as the source of truth instead, and explicitly flag in the handoff to Batch 2 that the install steps must be re-verified once F1.3 ships. Also lock in the following low-risk defaults (documented as assumptions to revisit only if they prove wrong, not hard blockers): (a) README stays text-only — no badges, screenshots, or GIFs; (b) section order = Hero/What-it-is → Installation (one-liner and copy-paste presented with equal prominence) → Re-install/update note → Quick start → Skill catalog → Agent catalog + Codex CLI caveat; (c) the skill/agent catalog is reproduced as full Markdown tables inline (adapted from `product-spec.md` §Catalog), not summarized with an outbound link; (d) the current README's `agents.md` mention is dropped entirely, since it appears nowhere in `product-spec.md` or `tech-spec.md` and is treated as stale/no-longer-applicable. Produce a short outline/decision note (which sections, in which order, sourced from which document) that Batch 2 tasks will follow.

## Batch 2 — Draft content sections

> **Batch 1 handoff — dependency check**
>
> **F1.3 is DONE and stable.** `setup-ai.md` (11 KB) exists at the repo root, merged to `main` in `d7bfdcf`
> (PR #4), with every batch of `specs/003-setup-ai-installer/plan.md` checked off including a live
> dummy-folder install (@tester) and a @judge PASS. `catalog.yaml` (12 commands + 6 agents) and
> `ai-toolkit/default/` (verified: exactly 12 `commands/*.md` + 6 `agents/*.md`, names matching
> `product-spec.md` §Catalog 1:1) are also on `main`.
> **→ `setup-ai.md` is the single source of truth for every install string.** No fallback to
> `product-spec.md`/`tech-spec.md` for install *mechanics*, and **no "re-verify once F1.3 ships" caveat
> is needed** — that instruction in the Batch 1 task and the closing Note below are both obsolete.
> Copy URLs and command forms from `setup-ai.md` verbatim; do not paraphrase them.
>
> **Batch 1 handoff — locked structure (supersedes defaults (a) and (b) in the Batch 1 task)**
>
> The Batch 1 task proposed defaults "to revisit only if they prove wrong". Two of them **are** wrong:
> they were derived from `requirements.md`'s raw `[NEEDS CLARIFICATION]` markers (FR-011..FR-014) without
> accounting for `specs/ui-spec.md`, which resolved those exact markers, is marked 🟢 **Locked for F1.4**,
> and records **direct user feedback** ("Ajuste post-entrevista"). `requirements.md` itself defers to it.
> Where the two disagree, **ui-spec wins**:
>
> | Item | Batch 1 task default | `ui-spec.md` (locked) | Ruling |
> |---|---|---|---|
> | (a) Badges | text-only, none | 3 static shields.io, `style=flat-square` | **ui-spec** — badges included |
> | (b) Section order | Hero → Installation → Re-install → Quick start → Catalog | Hero → Why → Quick start (install merged in) → Catalog → Project structure → Good to know | **ui-spec** |
> | (c) Catalog depth | full inline tables | full inline tables, always visible, no `<details>` | agree — **locked** |
> | (d) `agents.md` mention | drop entirely | drop entirely (stale) | agree — **locked** |
>
> **Locked section order for Batch 3 assembly** (exact emoji-prefixed heading strings: `ui-spec.md` L30–L44):
>
> | # | Section | Source of truth | Covers |
> |---|---|---|---|
> | 1 | `# My AIsy Toolkit` + 3 badges + 1-paragraph pitch | badge URLs verbatim from `ui-spec.md` §Badges; pitch from `product-spec.md` §Vision; tone from §Design Principles ("Keep it AIsy") | FR-001, FR-008 |
> | 2 | `## Why` — 4 bullets | `product-spec.md` §Problem Statement (4 rows → 4 bullets, 1:1, pain+cause compressed to one sentence each) | FR-001, FR-008, FR-009 |
> | 3 | `## Quick start` — **install and first run in one flow** | **`setup-ai.md`** §How to install (URLs, `claude "…"` / `codex "…"` forms) + Step 1 (the questions) + Wrap-up (the summary the agent prints); shape from `ui-spec.md` §"Quick start como sección principal" | FR-002, FR-003, FR-007, FR-010, SC-001, SC-004 |
> | 4 | `## Catalog — default profile` — Skills table (12) + Agents table (6) + Codex caveat | `product-spec.md` §Catalog **verbatim** (both tables, to avoid drift); caveat from §Catalog closing line + `setup-ai.md` Step 5 | FR-004, FR-005, FR-006, SC-003 |
> | 5 | `## Project structure` — short tree | `ui-spec.md` §"Project structure — árbol reducido" | supports FR-009 |
> | 6 | `## Good to know` — re-install/update note + params table + side-effects note | `product-spec.md` §Interfaces (Re-installation/update; `profile`/`agent` params) + `setup-ai.md` L7–L8 (side effects) and Step 4 (overwrite rules) | re-install edge case, ADR-004 |
>
> **Four refinements Batch 2/3 must apply on top of ui-spec** (all narrow, all justified):
>
> 1. **Equal prominence inside Quick start.** ui-spec's mock demotes copy-paste to a "Can't fetch URLs?"
>    fallback; FR-003/FR-010 and the requirements' first Edge Case want both methods equally discoverable.
>    Resolve by mirroring `setup-ai.md`'s own framing — two labeled options ("Option A — one-liner",
>    "Option B — copy-paste") under a "Pick whichever fits your agent. Both do exactly the same thing."
>    line. This keeps ui-spec's structural decision (no separate `## Installation` H2) while satisfying
>    both FRs. ui-spec's block is a mock, not verbatim copy.
> 2. **US3/FR-007 must stay pointable-at.** US3's Independent Test asks for a section "distinct from
>    installation and catalog". Since ui-spec merges install into Quick start, give the post-install part
>    its own H3 so it is a findable unit — structure Quick start as
>    `### 1. Install` / `### 2. Answer two questions` / `### 3. Run your first command` (`/constitution`,
>    with a pointer back to the catalog table as the menu of entry points).
>    **Note for Batch 4 @judge:** FR-007/US3 is satisfied by `## Quick start` → `### 3`, *by design* —
>    the absence of a standalone `## Quick start` separate from install is a locked decision, not a gap.
> 3. **Add `catalog.yaml` to the project-structure tree.** ui-spec's tree predates F1.2 and omits it;
>    it now exists at the root and is central to ADR-003.
> 4. **Set the `updated-` badge to the real authoring date**, not ui-spec's placeholder.
>
> **FR-010 interpretation (recorded so Batch 4 does not re-litigate it):** "complete an install entirely
> from the README's content" means *without any document outside this repo and without asking Carlos*.
> The copy-paste method inherently requires opening `setup-ai.md` (250 lines — inlining it in the README
> is not viable); the README satisfies FR-010 by naming that file, linking its GitHub blob URL, and giving
> its root path. Do **not** inline `setup-ai.md`'s agent instructions.
>
> **Remapping of the four Batch 2 tasks below onto the six locked sections:** hero task → §1 **and** §2
> (Why); installation task → §3 `### 1`/`### 2` **and** §6 (its "re-install/update callout" and params
> table move to `## Good to know`, per ui-spec, instead of sitting next to the install block); catalog task
> → §4 (unchanged); quick-start task → §3 `### 3` (it is a sub-block of Quick start, not its own H2).
> §5 (Project structure) has no task below — fold it into the Batch 3 assembly task.

- [x] @code-developer · Draft the "what is it" hero section (FR-001, FR-008, FR-009): Write 2-4 short paragraphs or bullets, jargon-free, with the "Keep it AIsy" light/easygoing tone (never corporate), stating what My AIsy Toolkit is (a distributable kit of skills and subagents for spec-driven development with AI coding agents — Claude Code, and Codex CLI in best-effort mode) and the problem it solves (per `product-spec.md` §Problem Statement: no centralized distribution, flows reinvented per repo, zero-dependency install). Keep it short enough that, combined with the installation section, a first-time reader can decide and install in under two minutes (SC-001).
- [x] @code-developer · Draft the installation section (FR-002, FR-003, FR-010): Document the one-liner method and the copy-paste method as two equally prominent, clearly labeled options — do not present one as primary and the other as a fallback (edge case: equal discoverability). Source the exact steps from whichever document Batch 1's task designated as source of truth. Include the `profile` (defaults to `default`) and target-agent parameters/behavior per `product-spec.md` §Interfaces. Add a short "re-installing / updating" callout stating that re-running either method always brings the latest catalog, adds new skills/agents, and updates existing files that changed (edge case: re-install/update behavior, per the "always the latest version" design principle).
- [x] @code-developer · Draft the catalog section (FR-004, FR-005, FR-006): Reproduce, as Markdown tables, all 12 `default`-profile skills with their one-line descriptions and all 6 subagents with their roles, copied/adapted verbatim from `product-spec.md` §Catalog (`default` profile) to avoid drift between the two documents. Immediately after the agent table, add the Codex CLI caveat: only the skills catalog is translated to `.codex/skills/` in best-effort mode, with no subagent equivalent (edge case: communicating the Codex limitation to Codex-intending readers).
- [x] @code-developer · Draft the quick-start / usage guide section (FR-007): Write a short section, clearly distinct from installation and from the catalog, telling a freshly-installed user what to do first — e.g., suggest starting with `/constitution` or `/product-spec` to bootstrap the target repo's specs, and point back at the skill catalog above as the menu of entry points. Keep it skimmable (bullets, not prose paragraphs).

## Batch 3 — Assemble and finalize

- [x] @code-developer · Assemble the final README.md: Combine the Batch 2 sections in the order locked in by Batch 1's decision note, and replace the current root `README.md` content in full (this removes the stale `agents.md` mention as decided in Batch 1). Do a final tone pass for directness, jargon-free language, and "Keep it AIsy" consistency across all sections (FR-008). Self-check the assembled file line by line against FR-001 through FR-010 and SC-001 through SC-004 before handing off for review, and note explicitly in the commit/handoff whether the install section was sourced from `setup-ai.md` (stable) or from `product-spec.md`/`tech-spec.md` (fallback, needs re-verification once F1.3 ships).

## Batch 4 — Review

- [ ] @judge · Review the finished README.md against every functional requirement and success criterion: confirm a first-time reader could plausibly grasp the pitch and complete either install method in under two minutes using only the README (US1 / SC-001 / SC-002 / FR-009); confirm the skill table lists all 12 skills and the agent table all 6 agents, matching `product-spec.md` §Catalog exactly, with no drift (US2 / SC-003); confirm the Codex CLI best-effort / skills-only caveat is present and clear (FR-006); confirm both install methods are documented completely and independently, with equal prominence (SC-004 / edge case); confirm the quick-start section exists and reads as distinct from install/catalog (US3 / FR-007); confirm tone is jargon-free and non-corporate throughout (FR-008); confirm the stale `agents.md` mention was removed (Batch 1 decision). Issue PASS or CHANGES_REQUESTED with concrete, line-level fixes if requirements are not met.

### Critical Files for Implementation
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\README.md (target — replaced in full in Batch 3)
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\setup-ai.md (**source of truth for all install strings** — exists, stable)
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\specs\ui-spec.md (**locked structure, badges, trees** — §README)
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\specs\product-spec.md (§Catalog verbatim, §Problem Statement, §Interfaces)
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\catalog.yaml (cross-check: 12 commands + 6 agents)
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\specs\tech-spec.md
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\specs\roadmap.md
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\specs\004-readme-as-product-front\requirements.md

~~Note: `setup-ai.md` ... does not exist in the repo yet ...~~ → **Obsolete (Batch 1).** `setup-ai.md`,
`catalog.yaml` and `ai-toolkit/default/` all exist on `main`. No fallback is used and no
"re-verify once F1.3 ships" caveat is carried into Batch 3's handoff. Note also that
`ui-spec.md` §"Estado aspiracional" (which says those files don't exist) is stale for the same reason —
its *design* decisions still hold, its *repo-state* claim does not.
