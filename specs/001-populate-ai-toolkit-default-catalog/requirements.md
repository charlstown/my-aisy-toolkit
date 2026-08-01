# Populate ai-toolkit/default/ catalog
Feature Branch: 001-populate-ai-toolkit-default-catalog

Created: 2026-08-01

Status: Draft

Input: User description: "specs\roadmap.md"

## User Scenarios & Testing (mandatory)

### User Story 1 - Bring the maintainer's local skills vault into the distributable catalog (Priority: P1)

The maintainer takes the 12 skill files and 6 subagent files that already exist and work in their local skills vault (`D:\MisProyectos\0_TEMPLATES\AI\SKILLS`) and brings them into this repo's `ai-toolkit/default/commands/` (skills) and `ai-toolkit/default/agents/` (subagents) folders, so that the `default` profile catalog is populated and ready to be fetched by the `setup-ai` installer. This is explicitly a copy/population task ("Copied from the maintainer's local skills vault... not authored from scratch", ADR-005) rather than authoring new content.

Why this priority: This is the only feature in Phase 1 with no dependencies (`Depends on: —`), and Phase 1 is described as delivering "the whole product as scoped for v1." Without a populated catalog there is nothing for the `setup-ai` installer to fetch, so every other Phase 1 deliverable (installer, README) is blocked on this content existing first.

Independent Test: Can be fully tested by inspecting `ai-toolkit/default/commands/` and `ai-toolkit/default/agents/` and confirming the 12 named skills and 6 named subagents are present as files, and delivers a populated, installable `default` profile catalog independent of whether the installer or README exist yet.

Acceptance Scenarios:

1. Given the maintainer's local skills vault contains the 12 skills (`/constitution`, `/product-spec`, `/tech-spec`, `/roadmap`, `/get-issues`, `/new-issue`, `/specify-feature`, `/clarify-feature`, `/grill-me`, `/plan-feature`, `/implement-feature`, `/clean-feature`) and 6 subagents (`architect`, `code-developer`, `test-developer`, `tester`, `ui-developer`, `judge`), When the population task is performed, Then `ai-toolkit/default/commands/` contains one file per skill and `ai-toolkit/default/agents/` contains one file per subagent.
2. Given the files have been copied into `ai-toolkit/default/`, When each file is inspected, Then it is a valid Claude Code native Markdown + YAML frontmatter file (matching the `.claude/commands/*.md` and `.claude/agents/*.md` style already used internally by this repo).
3. Given `ai-toolkit/default/` is now populated, When compared against this repo's own internal `.claude/commands/` and `.claude/agents/`, Then the two remain decoupled and independently editable, per ADR-005 (`ai-toolkit/default/` is the distributable catalog `setup-ai` fetches; `.claude/` is this repo's own internal-only copy).

## Edge Cases

- What happens when a file in the vault does not match the expected Claude Code native Markdown + YAML frontmatter format?
- How does the system handle a skill or subagent that exists in the vault under a different name or sub-path than expected?
- What happens on a future re-population (updating the catalog after the vault changes), given there is no automated sync between the vault and `ai-toolkit/default/` (Known Limitation, tech-spec.md)?
- How does the system handle a file that references repo-specific paths or context from the maintainer's vault/other projects that would not make sense for an end user installing this kit?

## Requirements (mandatory)

### Functional Requirements

- FR-001: System MUST result in `ai-toolkit/default/commands/` containing the 12 skill files: `/constitution`, `/product-spec`, `/tech-spec`, `/roadmap`, `/get-issues`, `/new-issue`, `/specify-feature`, `/clarify-feature`, `/grill-me`, `/plan-feature`, `/implement-feature`, `/clean-feature`.
- FR-002: System MUST result in `ai-toolkit/default/agents/` containing the 6 subagent files: `architect`, `code-developer`, `test-developer`, `tester`, `ui-developer`, `judge`.
- FR-003: The source of these files MUST be the maintainer's local skills vault at `D:\MisProyectos\0_TEMPLATES\AI\SKILLS`, not newly authored content (ADR-005).
- FR-004: Each populated file MUST be in Claude Code's native Markdown + YAML frontmatter format, consistent with the style already used in `.claude/commands/*.md` and `.claude/agents/*.md`.
- FR-005: `ai-toolkit/default/commands/` and `ai-toolkit/default/agents/` MUST remain decoupled from this repo's own `.claude/commands/` and `.claude/agents/` — the latter is never read by `setup-ai` and may diverge freely (ADR-005).
- FR-006: Users MUST be able to verify, after population, that each file is valid and usable as Claude Code native format (some form of post-copy validation).
- FR-007: System MUST NOT require any additional dependency or setup step beyond the populated catalog files themselves, consistent with the "Zero dependencies / zero friction" design principle.
- FR-008: The exact sub-path structure inside the vault to read files from is [NEEDS CLARIFICATION: source material does not specify the vault's internal folder layout, e.g. whether skills/agents live in flat folders, are split by category, or mirror the `.claude/` layout].
- FR-009: Whether file content MUST change during the copy (e.g., stripping repo-specific references from the maintainer's vault before landing in `ai-toolkit/default/`) is [NEEDS CLARIFICATION: source material explicitly flags this as unspecified].
- FR-010: Whether all 12 skill files and 6 agent files MUST be included verbatim, or whether the set should be curated (some included, some excluded/modified), is [NEEDS CLARIFICATION: source material explicitly flags this as unspecified].

### Key Entities

- Skill file: A single Claude Code native command (`.md` with YAML frontmatter) representing one of the 12 catalog skills (e.g. `/constitution`, `/plan-feature`); lives in `ai-toolkit/default/commands/` once populated; originates from the maintainer's local skills vault.
- Agent file: A single Claude Code native subagent definition (`.md` with YAML frontmatter) representing one of the 6 catalog subagents (e.g. `architect`, `judge`); lives in `ai-toolkit/default/agents/` once populated; originates from the maintainer's local skills vault.
- Default profile catalog: The combined set of the 12 skill files and 6 agent files under `ai-toolkit/default/`; the canonical, versioned content that `setup-ai` fetches to install the kit into a target repo; decoupled from this repo's internal `.claude/` directory.
- Maintainer's local skills vault: The external, canonical source directory (`D:\MisProyectos\0_TEMPLATES\AI\SKILLS`) from which the catalog's content is copied; not itself part of this repo; has no automated sync with `ai-toolkit/default/`.

## Success Criteria (mandatory)

### Measurable Outcomes

- SC-001: `ai-toolkit/default/commands/` contains exactly the 12 named skill files, and `ai-toolkit/default/agents/` contains exactly the 6 named agent files (18 files total).
- SC-002: 100% of the populated files parse as valid Claude Code native Markdown + YAML frontmatter (no malformed frontmatter or missing required fields).
- SC-003: `ai-toolkit/default/` and this repo's internal `.claude/commands/` and `.claude/agents/` remain two distinct, independently editable locations after population (no coupling introduced), satisfying ADR-005.
- SC-004: The populated catalog is sufficient, on its own, to unblock the next Phase 1 deliverables (the `setup-ai` installer and the install-focused README) with no further content-authoring work required for these 18 files.

## Assumptions

- The maintainer (not an automated process) performs this population task, and has direct filesystem access to `D:\MisProyectos\0_TEMPLATES\AI\SKILLS`.
- The files already present in the maintainer's vault are already valid, working Claude Code native skill/agent definitions (i.e., this is a population/copy task, not a from-scratch authoring task).
- This is a manual, repeatable-when-updating task rather than an automated or scripted sync pipeline, consistent with the Known Limitation noted in tech-spec.md ("no automated sync with its canonical source... updates are copied over by hand").
- The one short description already present per skill in product-spec.md's Interfaces catalog table is sufficient identification of scope and does not need to be re-derived here.
- This feature has no dependencies on other roadmap features (roadmap.md lists `Depends on: —` for F1.1).

## DEFINITION GAP

- [ ] What is the exact sub-path structure inside the vault (`D:\MisProyectos\0_TEMPLATES\AI\SKILLS`) that maps to `ai-toolkit/default/commands/` vs `ai-toolkit/default/agents/`?
- [ ] Does any file content need to change during the copy — for example, stripping repo-specific references or paths that only make sense in the maintainer's own environment — or should files be copied verbatim?
- [ ] Should all 12 skill files and 6 agent files be included exactly as they are in the vault, or should the set be curated (some excluded or trimmed) before landing in `ai-toolkit/default/`?
- [ ] What does "verifying afterward that they are still valid Claude Code native frontmatter files" mean concretely — is there a specific validation method/tool expected, or is this a manual/visual check?
- [ ] Is there any expectation for how future updates to the vault get re-synced into `ai-toolkit/default/` (even if manual), or is that entirely out of scope for this feature and left to the Known Limitation as-is?
