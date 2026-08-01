# Plan — README as product front

Source: specs/004-readme-as-product-front/requirements.md

## Context gathered

- **specs/product-spec.md** — has the full Catalog section (12 skills + 6 agents with descriptions/roles) that the README must mirror, plus the "README as product" design principle and install method definitions.
- **specs/tech-spec.md** — defines how `setup-ai` is supposed to work (ADR-001 through ADR-005), but confirms `setup-ai.md` and `ai-toolkit/default/` do not exist in the repo yet (only `specs/003-setup-ai-installer/requirements.md` and now its `plan.md` exist).
- **README.md** (current) — is a 2-line placeholder that mentions an `agents.md` file, which is absent from both product-spec.md and tech-spec.md.
- **specs/roadmap.md** — confirms F1.4 (this feature) depends on F1.3 (setup-ai) being done first, and the Gate Final Milestone criterion that the README alone must be enough for a stranger to install cleanly.

## Batch 1 — Structural decisions & dependency check

- [ ] @architect · Confirm F1.3 dependency and lock README structure: Check whether `setup-ai.md` exists at the repo root and is stable (status of spec `003-setup-ai-installer`). If it exists and is stable, use it as the source of truth for the one-liner and copy-paste install steps. If it does not yet exist or is still in draft (as of this planning round it does not exist in the repo), use `specs/product-spec.md` §Interfaces (Installation) and `specs/tech-spec.md` §Module Design / ADR-001..ADR-005 as the source of truth instead, and explicitly flag in the handoff to Batch 2 that the install steps must be re-verified once F1.3 ships. Also lock in the following low-risk defaults (documented as assumptions to revisit only if they prove wrong, not hard blockers): (a) README stays text-only — no badges, screenshots, or GIFs; (b) section order = Hero/What-it-is → Installation (one-liner and copy-paste presented with equal prominence) → Re-install/update note → Quick start → Skill catalog → Agent catalog + Codex CLI caveat; (c) the skill/agent catalog is reproduced as full Markdown tables inline (adapted from `product-spec.md` §Catalog), not summarized with an outbound link; (d) the current README's `agents.md` mention is dropped entirely, since it appears nowhere in `product-spec.md` or `tech-spec.md` and is treated as stale/no-longer-applicable. Produce a short outline/decision note (which sections, in which order, sourced from which document) that Batch 2 tasks will follow.

## Batch 2 — Draft content sections

- [ ] @code-developer · Draft the "what is it" hero section (FR-001, FR-008, FR-009): Write 2-4 short paragraphs or bullets, jargon-free, with the "Keep it AIsy" light/easygoing tone (never corporate), stating what My AIsy Toolkit is (a distributable kit of skills and subagents for spec-driven development with AI coding agents — Claude Code, and Codex CLI in best-effort mode) and the problem it solves (per `product-spec.md` §Problem Statement: no centralized distribution, flows reinvented per repo, zero-dependency install). Keep it short enough that, combined with the installation section, a first-time reader can decide and install in under two minutes (SC-001).
- [ ] @code-developer · Draft the installation section (FR-002, FR-003, FR-010): Document the one-liner method and the copy-paste method as two equally prominent, clearly labeled options — do not present one as primary and the other as a fallback (edge case: equal discoverability). Source the exact steps from whichever document Batch 1's task designated as source of truth. Include the `profile` (defaults to `default`) and target-agent parameters/behavior per `product-spec.md` §Interfaces. Add a short "re-installing / updating" callout stating that re-running either method always brings the latest catalog, adds new skills/agents, and updates existing files that changed (edge case: re-install/update behavior, per the "always the latest version" design principle).
- [ ] @code-developer · Draft the catalog section (FR-004, FR-005, FR-006): Reproduce, as Markdown tables, all 12 `default`-profile skills with their one-line descriptions and all 6 subagents with their roles, copied/adapted verbatim from `product-spec.md` §Catalog (`default` profile) to avoid drift between the two documents. Immediately after the agent table, add the Codex CLI caveat: only the skills catalog is translated to `.codex/skills/` in best-effort mode, with no subagent equivalent (edge case: communicating the Codex limitation to Codex-intending readers).
- [ ] @code-developer · Draft the quick-start / usage guide section (FR-007): Write a short section, clearly distinct from installation and from the catalog, telling a freshly-installed user what to do first — e.g., suggest starting with `/constitution` or `/product-spec` to bootstrap the target repo's specs, and point back at the skill catalog above as the menu of entry points. Keep it skimmable (bullets, not prose paragraphs).

## Batch 3 — Assemble and finalize

- [ ] @code-developer · Assemble the final README.md: Combine the Batch 2 sections in the order locked in by Batch 1's decision note, and replace the current root `README.md` content in full (this removes the stale `agents.md` mention as decided in Batch 1). Do a final tone pass for directness, jargon-free language, and "Keep it AIsy" consistency across all sections (FR-008). Self-check the assembled file line by line against FR-001 through FR-010 and SC-001 through SC-004 before handing off for review, and note explicitly in the commit/handoff whether the install section was sourced from `setup-ai.md` (stable) or from `product-spec.md`/`tech-spec.md` (fallback, needs re-verification once F1.3 ships).

## Batch 4 — Review

- [ ] @judge · Review the finished README.md against every functional requirement and success criterion: confirm a first-time reader could plausibly grasp the pitch and complete either install method in under two minutes using only the README (US1 / SC-001 / SC-002 / FR-009); confirm the skill table lists all 12 skills and the agent table all 6 agents, matching `product-spec.md` §Catalog exactly, with no drift (US2 / SC-003); confirm the Codex CLI best-effort / skills-only caveat is present and clear (FR-006); confirm both install methods are documented completely and independently, with equal prominence (SC-004 / edge case); confirm the quick-start section exists and reads as distinct from install/catalog (US3 / FR-007); confirm tone is jargon-free and non-corporate throughout (FR-008); confirm the stale `agents.md` mention was removed (Batch 1 decision). Issue PASS or CHANGES_REQUESTED with concrete, line-level fixes if requirements are not met.

### Critical Files for Implementation
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\README.md
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\specs\product-spec.md
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\specs\tech-spec.md
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\specs\roadmap.md
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\specs\004-readme-as-product-front\requirements.md

Note: `setup-ai.md` (the intended source of truth for the install steps, per `003-setup-ai-installer`) does not exist in the repo yet — this is why Batch 1's task builds in a fallback to `product-spec.md`/`tech-spec.md` rather than treating it as a hard blocker.
