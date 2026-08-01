# README as product front
Feature Branch: 004-readme-as-product-front

Created: 2026-08-01

Status: Draft

Input: User description: "specs\roadmap.md"

## User Scenarios & Testing (mandatory)

### User Story 1 - First-time visitor decides and installs (Priority: P1)

A developer who has never seen my-aisy-toolkit lands on the repository's README. In under two minutes they must understand what the kit is, be convinced it's worth adopting, and complete an installation using either the one-liner or the copy-paste method, without needing to ask Carlos or read any other document.

Why this priority: This is the explicit purpose of the feature per the product-spec Design Principle "README as product" ("the README is the kit's front: it must convince and allow installing in under 2 minutes") and the Gate Final Milestone criterion ("The README alone is sufficient for someone other than Carlos to reproduce a clean install without extra context"). Without this, the feature fails its core reason for existing.

Independent Test: Can be fully tested by handing the README to someone other than Carlos, with no other context, and having them attempt a clean install via either method; success is a working install completed without external help.

Acceptance Scenarios:

1. Given a developer with no prior knowledge of the project, When they read the README, Then they understand what the kit is (a distributable kit of skills/subagents for spec-driven development with AI coding agents) and what problem it solves.
2. Given a developer who decides to install, When they follow the README's one-liner instructions, Then the kit installs successfully in their target repo without consulting any file outside the README.
3. Given a developer who decides to install, When they follow the README's copy-paste instructions instead, Then the kit installs successfully the same way.

### User Story 2 - Existing/prospective user browses the default profile catalog (Priority: P2)

A developer who is already installing (or has installed) the kit wants to know exactly what they're getting: which skills and which agents are included in the `default` profile, and what each one does, before or after installing.

Why this priority: Explicitly required by the roadmap row for F1.4 ("Presents the kit, both install methods, and the `default` profile catalog") and the product-spec Deliverables entry for README ("...the `default` profile catalog..."). It is secondary to the install decision itself (US1) but is called out as a distinct, required piece of content.

Independent Test: Can be fully tested by checking the README against the product-spec's Catalog section and confirming all 12 skills (with one-line descriptions) and all 6 agents (with roles) are represented, along with the Codex CLI best-effort caveat.

Acceptance Scenarios:

1. Given a reader on the README, When they look for the skill catalog, Then they find all 12 `default`-profile skills, each with a short description of what it does.
2. Given a reader on the README, When they look for the agent catalog, Then they find all 6 `default`-profile subagents, each with its role.
3. Given a Codex CLI user reading the catalog, When they check what applies to them, Then the README states that only the skills catalog is translated to `.codex/skills/` in best-effort mode (no subagent equivalent).

### User Story 3 - Installed user looks for a quick usage guide (Priority: P3)

A developer who has just installed the kit wants a short pointer on how to actually start using it (e.g., which skill to invoke first) without digging through every skill file.

Why this priority: Explicitly listed in the product-spec Deliverables table for README ("...and a quick usage guide") but not elaborated on elsewhere in the source material, and not called out in the roadmap row or the Gate criterion the way install and catalog are. Treated as lower priority than convincing/installing (US1) and cataloging (US2).

Independent Test: Can be fully tested by checking whether the README contains a section, distinct from installation and catalog, that tells a freshly-installed user what to do next.

Acceptance Scenarios:

1. Given a developer who just finished installing the kit, When they look at the README, Then they find a short guide on getting started with the installed skills/agents.

## Edge Cases

- What happens when a reader only wants the copy-paste method (no shell access) — does the README make that path equally discoverable as the one-liner, or does it default to presenting one as primary?
- How does the README communicate the Codex CLI best-effort limitation (skills only, no subagent equivalent) to a reader who intends to use Codex CLI rather than Claude Code?
- What happens when a reader re-installs/updates an already-installed repo — does the README explain that re-running either method always brings the latest catalog and updates existing files, per the product-spec's "Always the latest version" principle?
- How does the README handle the discrepancy between the current README's mention of an `agents.md` file and its total absence from product-spec.md and tech-spec.md?

## Requirements (mandatory)

### Functional Requirements

- FR-001: The README MUST present the kit (what My AIsy Toolkit is and the problem it solves) clearly enough for a first-time reader to decide, in under two minutes, whether to install it.
- FR-002: The README MUST document the one-liner installation method.
- FR-003: The README MUST document the copy-paste installation method.
- FR-004: The README MUST present the `default` profile's skill catalog, listing all 12 skills with a one-line description each, consistent with the product-spec's Catalog section.
- FR-005: The README MUST present the `default` profile's agent catalog, listing all 6 subagents with their role each, consistent with the product-spec's Catalog section.
- FR-006: The README MUST state that Codex CLI support is best-effort and that only the skills catalog (not the agents catalog) is translated to `.codex/skills/`.
- FR-007: The README MUST include a quick usage guide for a user who has just installed the kit.
- FR-008: The README MUST be written in a direct, jargon-free tone with the "Keep it AIsy" light, easygoing touch, per the product-spec Design Principles, and MUST NOT read as corporate.
- FR-009: The README MUST be sufficient, on its own, for someone other than Carlos to reproduce a clean install without needing extra context (Gate Final Milestone criterion).
- FR-010: Users MUST be able to reach and complete an install using either method described, entirely from the README's content.
- FR-011: System MUST resolve the `agents.md` mention in the current README [NEEDS CLARIFICATION: the current README references an `agents.md` file that does not appear anywhere in product-spec.md or tech-spec.md — is this file still part of the product, was it dropped, or was the README simply wrong and should the mention be removed?]
- FR-012: The README's section order/structure is not specified in the source material [NEEDS CLARIFICATION: no explicit heading order or structure was provided beyond "presents the kit, both install methods, the catalog, and a quick usage guide" — what order and what additional sections, if any, are expected?]
- FR-013: Whether the README should include badges, screenshots, or GIFs is not specified [NEEDS CLARIFICATION: source material explicitly does not resolve this].
- FR-014: The level of detail for the catalog inside the README (full tables inline vs. a summary that links out to product-spec.md) is not specified [NEEDS CLARIFICATION: source material explicitly does not resolve this].

### Key Entities

Not applicable — this feature is a documentation artifact (the README file), not a data model.

## Success Criteria (mandatory)

### Measurable Outcomes

- SC-001: A first-time reader can go from opening the README to a completed installation (either method) in under 2 minutes.
- SC-002: A person other than Carlos can reproduce a clean install of the kit using only the README's content, with no additional context or explanation from Carlos (Gate Final Milestone criterion).
- SC-003: The README's skill catalog lists all 12 `default`-profile skills and the agent catalog lists all 6 `default`-profile agents, matching the product-spec's Catalog section.
- SC-004: The README documents both installation methods (one-liner and copy-paste) such that either one, followed independently, results in a working installation.

## Assumptions

- F1.3 (`setup-ai.md` installer, covering both install methods for Claude Code and best-effort Codex CLI) is complete and stable enough to be documented accurately in the README, per the roadmap's stated dependency (F1.4 depends on F1.3).
- The `default` profile catalog referenced in the README (12 skills, 6 agents) reflects the already-populated `ai-toolkit/default/` content from F1.1/F1.2.
- The README lives at the repository root, per the product-spec's Project Structure ("README.md # Project front: installation, catalog, usage").
- The target reader is a developer unfamiliar with the project who needs to self-serve an install without contacting Carlos.
- Stylistic inspiration from https://github.com/FlorianBruniaux/claude-code-ultimate-guide applies at a "improved and simplified" level of guidance only; no specific structural elements from that guide are mandated by the source material.

## DEFINITION GAP

All items below were resolved via the `/ui-spec` design interview; the resulting screen design is locked in [[ui-spec]] (§ README). Superseded by that document — kept here only as a decision log.

- [x] ~~The current README mentions an `agents.md` file that does not appear anywhere in product-spec.md or tech-spec.md. Is `agents.md` still part of the product, or should this mention be dropped?~~ → Dropped. It appears nowhere in product-spec.md or tech-spec.md and is treated as stale.
- [x] ~~What section order/structure should the new README follow?~~ → H1 + pitch → Why (problem, 4 bullets) → **Quick start** (install + first command `/constitution`, merged into one flow, no separate "Installation" section) → Catalog (`default` profile) → Project structure (short tree) → Good to know (reinstall/update note + params table). See [[ui-spec]] for the full mock.
- [x] ~~Should the README include badges, screenshots, or GIFs, or stay text-only?~~ → Minimal + 3 static shields.io badges (`skills-12`, `agents-6`, `updated-<date>`), `style=flat-square`. No Mermaid, no `<details>`, no screenshots/GIFs — the reference repo's density fits a 24k-line guide, not a 12-skill/6-agent kit.
- [x] ~~Should the skill/agent catalog be reproduced in full inside the README or summarized with a link out?~~ → Full Markdown tables, always visible (not collapsed in `<details>`) — only 18 rows total, copied verbatim from `product-spec.md` §Catalog to avoid drift.
- [x] ~~Confirm F1.3's install instructions are final/stable before the README's install sections are written.~~ → Not stable yet: `setup-ai.md`/`catalog.yaml`/`ai-toolkit/default/` don't exist in the repo as of this writing (F1.1–F1.3 still pending). The README was deliberately written as the **aspirational final version** anyway — the install command references `setup-ai.md` at its intended path, and must be re-verified once F1.3 ships (no "🚧 in progress" caveat was added, per the user's explicit choice).
- [x] ~~Which specific elements of the reference guide should be borrowed vs. simplified?~~ → Borrowed: discrete status badges. Dropped: Mermaid diagrams, `<details>` collapsibles, comparison matrices, star history, ecosystem quadrant — none fit a kit this size.
