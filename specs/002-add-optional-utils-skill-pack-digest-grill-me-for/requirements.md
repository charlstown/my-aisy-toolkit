# Add optional "Utils" skill pack (digest, grill-me, for-dummies) to setup-ai's install flow
Feature Branch: 002-add-optional-utils-skill-pack-digest-grill-me-for
Source Issue: https://github.com/charlstown/my-aisy-toolkit/issues/33

Created: 2026-08-02

Status: Draft

Version Bump: major (PR title prefix: `release: ...`)

Input: User description: "todas las issues en gh"

## User Scenarios & Testing (mandatory)

### User Story 1 - Opt into Utils skills during setup (Priority: P1)

After the existing agent + profile questions in Step 1, if the catalog declares a `packs.utils` section, `setup-ai` shows a single grouped question listing each util skill (`digest`, `grill-me`, `for-dummies`) with a one-line description, under a "Utils" header, numbered, and the user replies with comma-separated numbers, "all", or leaves it blank/unclear.

Why this priority: This is the core deliverable of the issue — the grouped-checklist question (Option A design) that lets users optionally install non-profile skills, extending `catalog.yaml` and `setup-ai.md`.

Independent Test: Run `setup-ai`, reach the point after the profile question, verify the Utils question is shown listing digest/grill-me/for-dummies, reply with a selection (e.g. "1,3"), and confirm only those skills are installed with the `aisy.` prefix.

Acceptance Scenarios:

1. Given the catalog declares a `packs.utils` section, When the user reaches the point after the profile question in Step 1, Then `setup-ai` shows a single grouped-checklist question listing each util skill with a one-line description under a "Utils" header, numbered.
2. Given the Utils question is shown, When the user replies with comma-separated numbers or "all", Then every selected util is written into the repo's `.claude/commands/` (or `.codex/skills/`, translated per the existing Step 5 rules) with the `aisy.` prefix (e.g. `aisy.digest.md`, `aisy.grill-me.md`, `aisy.for-dummies.md`).
3. Given the Utils question is shown, When the user leaves the answer blank or gives an unclear reply, Then nothing extra is installed and the flow continues silently (non-blocking, same treatment as Step 6's launcher offer), without repeating the question.

### User Story 2 - See installed utils in the Wrap-up report (Priority: P2)

After setup completes, the Wrap-up report lists installed utils in their own section, separate from the profile's core "Installed" files.

Why this priority: Reporting/visibility of the outcome of User Story 1; depends on it but is a distinct, separately observable behavior.

Independent Test: Run `setup-ai`, select one or more utils, complete setup, and verify the Wrap-up report contains a distinct Utils section listing the installed util skills separately from the core profile files.

Acceptance Scenarios:

1. Given one or more utils were selected and installed, When setup completes, Then the Wrap-up report shows the selected utils in their own section, distinct from the profile's core files section.

### User Story 3 - Explain concepts on demand with for-dummies (Priority: P2)

A user invokes the `for-dummies` skill with any vague prompt — one or more concepts, ideas, a link, or a document. The skill acts like an excellent teacher: it identifies the key concepts/terms present in the input and explains each one with examples, moving from concept to concept until everything requested is clear. It addresses at most 3 concepts per invocation; if more are detected, it asks the user which ones to address. If the input already narrows down to one or two specific concepts (a named technology, framework, or idea), it explains those directly without asking. To build sound explanations it searches the internet, prioritizing official documentation when available, and may include up to 3 free, immediately accessible resources (videos, articles, "knowledge pills") per concept — resources are optional, since the explanatory text itself must fully convey the concept on its own. It also offers the option to go deeper into any explained concept.

Why this priority: `for-dummies` is one of the three Utils skills this issue installs; its exact behavior was explicitly left undefined by the issue and was resolved during clarification (see below) rather than deferred further.

Independent Test: Invoke `for-dummies` with a prompt containing 2 concepts and verify it explains each with examples and, optionally, up to 3 resources; invoke it with 5 concepts and verify it asks the user which ones (up to 3) to address before explaining.

Acceptance Scenarios:

1. Given a vague prompt mentioning a single concept, technology, or framework, When `for-dummies` is invoked, Then it explains that concept directly with examples and, optionally, up to 3 free accessible resources.
2. Given a prompt that mentions more than 3 concepts, When `for-dummies` is invoked, Then it asks the user which concepts (up to 3) they want addressed before explaining any of them.
3. Given a concept has been explained, When the user wants more detail, Then `for-dummies` offers the option to go deeper into that concept.

## Edge Cases

- If the catalog does not declare a `packs.utils` section, the Utils question simply does not appear — no error or warning is shown; the setup flow continues normally without it.
- A reply that mixes valid and invalid numbers (e.g. "1,9" when only 3 utils exist) is treated as an unclear reply: zero utils are installed, same as a blank or fully invalid answer.

## Requirements (mandatory)

### Functional Requirements

- FR-001: `catalog.yaml` MUST gain a way to declare optional non-profile packs (e.g. a `packs:` top-level key) containing `utils: [digest, grill-me, for-dummies]`.
- FR-002: `setup-ai.md` MUST add a single, non-blocking, grouped-checklist question for Utils (Option A design: one screen, numbered items, "Utils" header, reply by numbers/"all"/blank), placed after the existing profile question.
- FR-003: The system MUST show the Utils question only if the catalog declares a `packs.utils` section, after the existing agent + profile questions in Step 1.
- FR-004: Each util skill in the question MUST be listed with a one-line description reusing that skill's existing description (translated to English if not already in English): `digest` — "From a vague user prompt (a doubt, a fear, or a reflection), runs a short interrogation (max 3 questions) to narrow down what and how to research, does brief internet research on trends, articles, or documents related to the topic, and always closes with at least 1 recommendation and 1 alternative (option B), justifying the reasoning behind the recommended decision."; `grill-me` — "Critical interrogation of a document to reduce gaps, clarify decisions, and detect inconsistencies. When finished, rewrites the document with everything learned. Requires an input document."; `for-dummies` — "Explains one or more concepts from a vague prompt, link, or document like an expert teacher, with examples and up to 3 optional free resources per concept."
- FR-005: The user MUST be able to reply with comma-separated numbers, "all", or leave the answer blank/unclear; any reply containing an out-of-range or otherwise invalid number MUST be treated as unclear, installing zero utils, even if it also contains valid numbers.
- FR-006: Selected utils MUST be written with the `aisy.` prefix in their filename, both for Claude Code (`.claude/commands/aisy.<skill>.md`) and Codex CLI (`.codex/skills/aisy.<skill>/SKILL.md`, translated per existing Step 5 rules).
- FR-007: An unclear or missing answer MUST install zero utils and MUST NOT block or repeat the question.
- FR-008: The Wrap-up report MUST show selected utils in their own section, distinct from the profile's core "Installed" files.
- FR-009: `digest` and `grill-me` MUST be added to this repo's source-of-truth catalog tree (`ai-toolkit/...`) as the initial Utils pack content.
- FR-010: The `for-dummies` skill MUST accept any vague prompt (one or more concepts, ideas, a link, or a document) and identify the key concepts/terms it contains.
- FR-010a: The skill MUST explain each identified concept like an expert teacher, using examples, moving from concept to concept until everything requested is clear.
- FR-010b: The skill MUST address at most 3 concepts per invocation; if more than 3 are detected, it MUST ask the user which ones to address before explaining any of them.
- FR-010c: If the input already specifies one or two concepts clearly (e.g. a named technology, framework, or idea), the skill MUST explain those directly without asking for concept selection.
- FR-010d: The skill MUST search the internet for supporting information, prioritizing official documentation when available.
- FR-010e: The skill MAY include up to 3 free, immediately accessible resources (e.g. videos, articles, "knowledge pills") per concept; resources are optional — the explanatory text itself MUST fully convey the concept on its own.
- FR-010f: The skill MUST offer the user the option to go deeper into any explained concept.
- FR-011: This feature's scope MUST be limited to the Utils category only; a separate `ui-ux` profile is out of scope and tracked in a separate issue.

### Key Entities (include if feature involves data)

- Utils pack: An optional, non-profile group of skills (`digest`, `grill-me`, `for-dummies`) declared under `packs.utils` in `catalog.yaml`, installable independently of the chosen profile's mandatory "core" skills.
- Util skill: An individual skill within the Utils pack (e.g. `digest`), installed with the `aisy.` prefix to avoid name collisions with the user's own skills or other toolkits.

## Success Criteria (mandatory)

### Measurable Outcomes

- SC-001: `catalog.yaml` declares a `packs:` top-level key containing `utils: [digest, grill-me, for-dummies]`.
- SC-002: `setup-ai.md` presents exactly one non-blocking, grouped-checklist Utils question, positioned after the existing profile question.
- SC-003: 100% of selected utils are written with the `aisy.` prefix in the correct location for the target agent (Claude Code or Codex CLI).
- SC-004: A blank or unclear reply to the Utils question results in zero utils installed and no repeated/blocking prompt.
- SC-005: The Wrap-up report contains a Utils section separate from the core "Installed" files section whenever at least one util was selected.
- SC-006: `digest` and `grill-me` exist in the repo's source-of-truth catalog tree (`ai-toolkit/...`) as Utils pack content.

## Assumptions

- The "Option A" design (single-screen grouped checklist, `aisy.` namespace) referenced in the issue was already agreed upon in a prior `/digest` exploration and is treated as the fixed direction for this feature, not open for reconsideration.
- The existing Step 5 (translation rules for Claude Code vs. Codex CLI) and Step 6 (launcher offer, non-blocking treatment) referenced in the issue already exist in `setup-ai.md` and are reused as-is.
- `for-dummies`'s design should be informed by looking at similar existing tutor/learning-oriented skills for structural inspiration, per the clarification given for this feature.

