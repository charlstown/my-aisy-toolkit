# Add "ui-ux" profile with new ui-spec and clarify-uix skills
Feature Branch: 001-add-ui-ux-profile-with-new-ui-spec-and-clarify-uix
Source Issue: https://github.com/charlstown/my-aisy-toolkit/issues/34

Created: 2026-08-02

Status: Draft

Version Bump: minor (PR title prefix: `feature: ...`)

Input: User description: "todas las issues en gh"

## User Scenarios & Testing (mandatory)

### User Story 1 - Choose the ui-ux profile at setup (Priority: P1)

At Step 1's profile question, a user setting up the toolkit sees `ui-ux` as an additional profile option alongside `default`, with its own file/skill count. Choosing `ui-ux` installs every file already listed under `default`, plus `ui-spec.md` and `clarify-uix.md`.

Why this priority: This is the entry point that makes the new profile discoverable and installable; without it, the `ui-spec` and `clarify-uix` skills authored for this feature cannot be delivered to users.

Independent Test: Run Step 1's profile selection and confirm `ui-ux` is listed alongside `default` with a correct file count; select it and verify the installed files equal `default`'s files plus `ui-spec.md` and `clarify-uix.md`.

Acceptance Scenarios:

1. Given a user at Step 1's profile question, When the profile options are displayed, Then `ui-ux` appears alongside `default` with its own file/skill count.
2. Given a user selects the `ui-ux` profile, When installation completes, Then every file already listed under `default` is installed, plus `ui-spec.md` and `clarify-uix.md`.

### User Story 2 - Generate a UI spec top-down with ui-spec (Priority: P2)

A user with the `ui-ux` profile invokes the `ui-spec` skill. The skill interviews the user top-down about a UI screen (content structure → layout → interaction/states → devices/accessibility) and writes/updates `specs/ui-spec.md`, following the reference style: staged rounds gated on resolving higher-level ambiguity before moving to the next, ASCII mockups presented before each question round, ready-made per-screen-type question sets, and a self-critique pass before writing.

Why this priority: This is one of the two new skills the profile exists to deliver, and it is the primary generalized deliverable (`specs/ui-spec.md`).

Independent Test: Invoke `ui-spec` on a UI screen, walk through the top-down staged rounds, and verify `specs/ui-spec.md` is written/updated and reflects the interrogation.

Acceptance Scenarios:

1. Given a user invokes `ui-spec` for a screen, When the interrogation proceeds, Then it runs top-down (content structure → layout → interaction/states → devices/accessibility) with each round gated on resolving the prior round's ambiguity.
2. Given a round begins, When the skill presents it to the user, Then an ASCII mockup is shown before the question round.
3. Given the interrogation concludes, When the skill is about to write output, Then it performs a self-critique pass before writing `specs/ui-spec.md`.

### User Story 3 - Choose interrogation length with clarify-uix (Priority: P2)

A user with the `ui-ux` profile invokes the `clarify-uix` skill, a UI/UX-focused counterpart to the existing `clarify-feature` skill. Instead of a fixed number of rounds, the user chooses the interrogation length upfront (e.g. 4, 8, or 12 questions), then the skill runs that many questions in the same top-down/staged style as `ui-spec`.

Why this priority: This is the second of the two new skills the profile exists to deliver.

Independent Test: Invoke `clarify-uix`, select a question count (e.g. 4, 8, or 12), and verify the skill runs exactly that many questions in the top-down/staged style used by `ui-spec`.

Acceptance Scenarios:

1. Given a user invokes `clarify-uix`, When the skill starts, Then it asks the user how many questions they want (e.g. 4, 8, or 12) before beginning the interrogation.
2. Given a question count is chosen, When the interrogation runs, Then it proceeds in that many questions, in the same top-down staged/gated style as `ui-spec`.

## Edge Cases

- What happens when the `ui-ux` profile's relationship to the separate "Utils pack" feature is considered — the issue states they are an independent mechanism (`ui-ux` is a full profile, a superset of `default`, not an optional pack layered on top of a chosen profile), so how do the two interact if both are relevant to a given setup?
- How does the system handle differences between the referenced `facturito` `ui-spec.md` skill (used only as a style/structure reference) and this toolkit's generalized version, given it must generalize beyond that specific project rather than being copied verbatim?

## Requirements (mandatory)

### Functional Requirements

- FR-001: `catalog.yaml` MUST gain a `ui-ux` profile whose `commands`/`agents` lists equal `default`'s lists plus `ui-spec.md` and `clarify-uix.md`.
- FR-002: Step 1's profile question MUST list `ui-ux` alongside `default`, with correct file counts, using the same presentation format/UX already used for existing profile options (no special visual treatment), listed after `default`.
- FR-003: The `ui-spec` skill MUST be authored in this repo's catalog source tree, following the structure/style of the referenced `facturito` `ui-spec.md` (top-down rounds, gated progression, ASCII mockups, self-critique pass), adapted to write `specs/ui-spec.md` in a way that generalizes beyond the reference project. During planning, its concrete interrogation questions and per-screen-type question sets MUST be adapted from that reference file's structure rather than designed from scratch.
- FR-004: The `ui-spec` skill MUST interview the user top-down about a UI screen (content structure → layout → interaction/states → devices/accessibility) and write/update `specs/ui-spec.md`.
- FR-005: The `clarify-uix` skill MUST be authored, mirroring `clarify-feature`'s purpose but letting the user pick the interrogation length (e.g. 4/8/12 questions) before it begins, in the same top-down staged style as `ui-spec`.
- FR-006: The `clarify-uix` skill MUST offer exactly 3 fixed question-count options — 4, 8, or 12 — with no free-form number entry. It MUST analyze how much UI/UX scope or complexity is at hand and mark one of the three options as "(recommended)" accordingly, then proceed in exactly the chosen number of questions.
- FR-007: The `ui-spec` skill's self-critique pass MUST review coherence across the drafted document's sections and check that no key question remains unanswered, adjusting the draft before writing `specs/ui-spec.md` if issues are found.

### Key Entities (include if feature involves data)

- `ui-ux` profile: an entry in `catalog.yaml` whose `commands`/`agents` lists equal `default`'s lists plus `ui-spec.md` and `clarify-uix.md`.
- `ui-spec` skill: generates/updates `specs/ui-spec.md` through a top-down interrogation, referenced against the `facturito` project's `/ui-spec` skill (`D:\00_WIP\2602_FacturasAPP\facturito\.claude\commands\ui-spec.md`) as a style/structure reference.
- `clarify-uix` skill: a UI/UX-focused counterpart to `clarify-feature`, with a user-chosen interrogation length.
- `specs/ui-spec.md`: the output document written/updated by the `ui-spec` skill.

## Success Criteria (mandatory)

### Measurable Outcomes

- SC-001: `catalog.yaml`'s `ui-ux` profile `commands`/`agents` lists exactly equal `default`'s lists plus `ui-spec.md` and `clarify-uix.md`.
- SC-002: Step 1's profile question displays `ui-ux` alongside `default`, each with an accurate file/skill count.
- SC-003: The `ui-spec` skill produces/updates `specs/ui-spec.md` via a top-down, staged interrogation with gated rounds, an ASCII mockup before each round, and a self-critique pass before writing.
- SC-004: The `clarify-uix` skill prompts the user for a desired number of questions — exactly 4, 8, or 12 — before starting, marking one option as "(recommended)" based on the analyzed UI/UX scope, then runs exactly that many questions in the top-down staged style.

## Assumptions

- The `default` profile's current `commands`/`agents` lists in `catalog.yaml` are the baseline that `ui-ux` must be a superset of (the issue does not restate this list; it references it by name only).
- The `facturito` project's `/ui-spec` skill (`D:\00_WIP\2602_FacturasAPP\facturito\.claude\commands\ui-spec.md`) is treated strictly as an external, read-only style/structure reference and is not to be copied verbatim.

