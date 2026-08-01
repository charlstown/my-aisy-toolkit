# catalog.yaml manifest
Feature Branch: 002-catalog-yaml-manifest

Created: 2026-08-01

Status: Draft

Input: User description: "specs\roadmap.md"

## User Scenarios & Testing (mandatory)

### User Story 1 - Consuming agent installs the default profile from a single manifest (Priority: P1)

An agent or tool installing the toolkit into a target repo needs to know which skills and agents belong to the `default` profile and where their source lives, without needing a tool that can list remote directories. It fetches `catalog.yaml` from the repo root and reads, for the `default` profile, the declared list of skills/agents and their source paths, then uses that list to fetch and install each item.

Why this priority: This is the entire reason ADR-003 exists — replacing dynamic directory listing (which not all agents can do) with an explicit, fetchable manifest. Without this, no installation can happen.

Independent Test: Fetch `catalog.yaml` directly by URL and parse it to enumerate the `default` profile's skills and agents with their source paths, with no other tool or API call involved.

Acceptance Scenarios:

1. Given the repo has `catalog.yaml` at its root, When an agent that can only fetch a known URL requests it, Then it receives a manifest declaring the `default` profile's skill/agent list and source paths.
2. Given the `default` profile is documented in product-spec.md's Interfaces catalog table as containing 12 skills and 6 agents, When `catalog.yaml` is parsed, Then all 18 entries appear under the `default` profile with a source path each.

### User Story 2 - Maintainer defines profiles independently of folder structure (Priority: P2)

A maintainer of the toolkit repo needs `catalog.yaml`'s structure to declare profiles independently of the repo's actual folder layout, so that today's single `default` profile and any future profiles can be represented without redesigning the installation mechanism.

Why this priority: Directly stated as a design principle in product-spec.md ("Extensible profiles from day one") and as a named consequence of ADR-003 ("independent of folder structure"). It is secondary to User Story 1 because the manifest must first work for the one profile that exists today.

Independent Test: Confirm the manifest's structure keys entries by profile name (not by directory path), so a hypothetical second profile could be added as a new entry without altering how the `default` profile is declared or consumed.

Acceptance Scenarios:

1. Given only the `default` profile exists today, When `catalog.yaml` is structured, Then its schema groups skills/agents under a named profile rather than being tied to a fixed directory listing.
2. Given a future profile were added, When it is declared in `catalog.yaml`, Then no change to the schema used by the `default` profile is required (per tech-spec.md Discovery: a single `catalog.yaml` is assumed sufficient even as profiles grow).

### User Story 3 - Maintainer keeps the manifest in sync when adding new files (Priority: P3)

A maintainer adding a new skill or agent to the `default` profile needs a way to confirm that `catalog.yaml` still matches the actual set of files in the profile, so the manifest doesn't silently drift out of sync with the real catalog contents.

Why this priority: ADR-003 explicitly calls out manifest drift as a risk and names a mitigation (the manual scratch-repo test must check that every new file in the profile appears in `catalog.yaml`). This is a safeguard around the core mechanism, not the mechanism itself, hence lower priority than User Stories 1 and 2.

Independent Test: Add a new file to the `default` profile's source directories and run the manual scratch-repo test; the test should surface whether the new file is missing from `catalog.yaml`.

Acceptance Scenarios:

1. Given a new skill or agent file is added to the repo under the `default` profile, When the manual scratch-repo test is run, Then it includes a check for whether the new file appears in `catalog.yaml`.
2. Given a file exists in the profile's source paths but is absent from `catalog.yaml`, When the check described above runs, Then the drift is detectable (exact detection mechanism beyond the manual test is not specified — see DEFINITION GAP).

## Edge Cases

- What happens when a skill or agent file exists in the repo's `default` profile directories but is missing from `catalog.yaml` (the drift scenario ADR-003 names as a risk)?
- What happens when `catalog.yaml` is malformed or fails to parse?
- How does the mechanism behave for a consuming agent that can only fetch a known URL versus one that could otherwise list remote directories (the compatibility case ADR-003 is designed around)?
- What happens when a second profile is introduced — does the existing `default` profile's declaration need to change (tech-spec.md Discovery says no, but the exact mechanics aren't specified)?

## Requirements (mandatory)

### Functional Requirements

- FR-001: System MUST provide a single `catalog.yaml` file at the repository root.
- FR-002: `catalog.yaml` MUST declare, per profile, the list of skills and agents included in that profile.
- FR-003: `catalog.yaml` MUST declare, for each skill and agent entry, its source path within the repository.
- FR-004: `catalog.yaml` MUST be written in YAML format.
- FR-005: `catalog.yaml` MUST declare the `default` profile containing the skills and agents enumerated in product-spec.md's Interfaces catalog table (12 skills and 6 agents).
- FR-006: `catalog.yaml`'s structure MUST allow additional profiles to be declared without requiring a redesign of the installation mechanism.
- FR-007: `catalog.yaml` MUST be usable by a consuming agent that can only fetch a known URL, without requiring the agent to list remote directories via an API.
- FR-008: The installation mechanism MUST NOT rely on dynamically listing `.claude/commands/` and `.claude/agents/` (or equivalent remote directories) to determine profile contents; `catalog.yaml` replaces that approach per ADR-003.
- FR-009: System MUST support a manual verification step (per the scratch-repo test) that checks whether every new file added to a profile appears in `catalog.yaml`.
- FR-010: The exact YAML schema/field names for `catalog.yaml` (e.g. `profiles.default.skills[]` vs. an alternative structure) are [NEEDS CLARIFICATION: schema/field naming not specified in source material].
- FR-011: Whether `catalog.yaml` must also declare per-target-agent destination paths (e.g. Codex's `.codex/skills/<name>/SKILL.md` naming convention) or only the Claude Code source paths in this repo is [NEEDS CLARIFICATION: not specified in source material].
- FR-012: How a consuming agent or tool should validate `catalog.yaml`'s structure before trusting it is [NEEDS CLARIFICATION: no validation approach specified in source material].

### Key Entities

- Catalog Manifest (`catalog.yaml`): a single YAML file at the repo root; the top-level structure organizes entries by profile.
- Profile: a named grouping (e.g. `default`) declaring which skills and agents belong to it. Only `default` exists today; the structure must remain extensible to future profiles without redesign.
- Skill/Agent Entry: an item within a profile that references a skill's or agent's source path in the repository. The `default` profile currently comprises 12 skills and 6 agents (per product-spec.md's Interfaces catalog table).

## Success Criteria (mandatory)

### Measurable Outcomes

- SC-001: All 18 entries of the `default` profile (12 skills + 6 agents) documented in product-spec.md's Interfaces catalog table are represented in `catalog.yaml` with a source path each.
- SC-002: A consuming agent limited to fetching a known URL (no directory-listing capability) can determine the full contents of the `default` profile using only `catalog.yaml`.
- SC-003: The manual scratch-repo test, when run after adding a new file to the `default` profile, includes a check confirming the new file appears in `catalog.yaml`.
- SC-004: Adding a hypothetical second profile to `catalog.yaml` requires no change to the schema used to declare the existing `default` profile.

## Assumptions

- F1.1 (the roadmap dependency of this feature) is completed before or alongside this feature; its exact deliverable is not described in the given source material.
- The `default` profile's skill/agent list, as enumerated in product-spec.md's Interfaces catalog table (12 skills, 6 agents), is the authoritative content `catalog.yaml` must represent at this time.
- YAML is the assumed serialization format for the manifest, per tech-spec.md's Tech Stack table, following the `reference.yaml` pattern from the FlorianBruniaux/claude-code-ultimate-guide reference repo.
- A single `catalog.yaml` file (not split across multiple files) is sufficient for the foreseeable number of profiles, per tech-spec.md's Discovery resolution.

## DEFINITION GAP

- [ ] What is the exact YAML schema for `catalog.yaml` (field/key names, nesting) — e.g. `profiles.default.skills[]` and `profiles.default.agents[]`, or a different structure?
- [ ] Does `catalog.yaml` need to declare per-target-agent destination paths (e.g. Codex's `.codex/skills/<name>/SKILL.md` naming), or only the Claude Code source paths within this repo?
- [ ] How should a consuming agent or tool validate `catalog.yaml`'s structure before trusting it (required fields, schema validation, handling of malformed YAML)?
- [ ] What exactly does F1.1 deliver, and what interface or contract does F1.2 depend on from it?
- [ ] Beyond the manual scratch-repo test, is there any automated check for `catalog.yaml` drift (a declared source path that doesn't exist, or an existing file omitted from the manifest)?
