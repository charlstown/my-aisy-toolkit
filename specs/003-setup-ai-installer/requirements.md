# setup-ai.md installer
Feature Branch: 003-setup-ai-installer

Created: 2026-08-01

Status: Draft

Input: User description: "specs\roadmap.md"

## User Scenarios & Testing (mandatory)

### User Story 1 - Install the default profile via one-liner (Priority: P1)

A user working inside their target repo pastes a single command (or asks their AI agent to run it) that fetches and installs the `my-aisy-toolkit` default profile. The installer always asks the user which profile to install (defaulting to `default` when only one exists, or asking if more than one profile is available and none was specified) and which target agent to install for (Claude Code or Codex CLI), per ADR-004. It then writes the corresponding skill/agent files into `.claude/` and/or `.codex/` inside the target repo, translating to Codex format at install time when Codex is the target (ADR-002).

Why this priority: This is the primary, roadmap-named installation method (F1.3) and the one the Phase 1 gate criterion exercises first ("both install methods with Claude Code as the target").

Independent Test: Can be fully tested by running the one-liner in a dummy folder with Claude Code as the target agent, and verifying every file declared in `catalog.yaml` for the `default` profile was installed and matches its `ai-toolkit/default/` source unmodified.

Acceptance Scenarios:

1. Given an empty target repo and the one-liner is run, When the user is asked for profile and target agent and answers "default" and "claude", Then all files declared in `catalog.yaml` for the `default` profile are fetched and written unmodified into `.claude/`.
2. Given an empty target repo and the one-liner is run, When the user selects "codex" as the target agent, Then the installer translates each fetched skill/agent to `.codex/skills/*/SKILL.md` format at install time (best-effort, per ADR-002).
3. Given the manifest (`catalog.yaml`) fetch returns 404 or is unreachable, When the one-liner runs, Then the installation aborts and the user is informed, with nothing written.

### User Story 2 - Install the default profile via copy-paste (Priority: P2)

A user copies a plain-text instructions block and pastes it directly into the conversation of any AI coding agent (no script execution). The agent interprets the instructions itself and performs the same installation behavior as the one-liner: it asks for profile and target agent, fetches the manifest and files, and writes/translates them into the target repo.

Why this priority: Named as the second of the two required install methods in the roadmap and product-spec, and is exercised by the same Phase 1 gate check as the one-liner.

Independent Test: Can be fully tested by pasting the copy-paste block into a fresh agent conversation pointed at a dummy folder with Claude Code as the target, and verifying every file declared in `catalog.yaml` for the `default` profile was installed and matches its `ai-toolkit/default/` source unmodified.

Acceptance Scenarios:

1. Given a user pastes the copy-paste instructions block into an AI agent conversation with no prior installation, When the agent interprets and executes the instructions, Then it asks the user for profile and target agent before writing anything.
2. Given the same copy-paste flow, When a skill/agent file fetch returns 404 or times out, Then the installer retries once, and if it still fails, informs the user and skips that file without blocking installation of the rest.

### User Story 3 - Re-install / update an already-installed repo (Priority: P3)

A user runs either install method (one-liner or copy-paste) again on a repo that already has the kit installed. The installer always fetches the latest catalog version (no semantic versioning), adds any new skills/agents not yet present, and updates/overwrites any that have changed, without touching application code or other folders outside `.claude/`/`.codex/`.

Why this priority: Described in product-spec as a supported flow of the same installer, but it is a variation on Stories 1 and 2 rather than a distinct delivery mechanism, and the roadmap's Phase 1 gate criterion does not name it explicitly.

Independent Test: Can be fully tested by running an install method a second time on a repo already containing an older/partial copy of the kit, and verifying the result matches a fresh install of the current catalog (new files added, changed files overwritten, unrelated files untouched).

Acceptance Scenarios:

1. Given a target repo already has some `default` profile files installed, When the installer is run again, Then any files whose source content differs from what's installed are overwritten with the latest version.
2. Given a target repo already has some `default` profile files installed, When the catalog now declares additional skills/agents not previously installed, Then those new files are added.
3. Given a target repo has files inside `.claude/` or `.codex/` that already exist with content different from the source, When the installer re-runs, Then it overwrites them (per "always latest version" principle), and it does not modify any file outside `.claude/`/`.codex/`.

## Edge Cases

- What happens when the manifest (`catalog.yaml`) fetch returns 404 or is unreachable? Installation aborts and the user is informed (per tech-spec Error Handling table).
- What happens when an individual skill/agent file fetch returns 404 or times out? The installer retries once, then informs the user and skips that file without blocking installation of the rest (per tech-spec Error Handling table).
- What happens when a target repo file already exists with different content than the source? The installer overwrites it, per the "always latest version" principle (no semantic versioning, no merge).
- What happens when the user does not confirm whether the target is Claude Code or Codex CLI? The installer asks again and writes nothing until answered (per tech-spec Error Handling table and ADR-004).
- What happens when more than one profile exists in the catalog and the user did not specify one? The installer asks the user to choose (per product-spec Interfaces > Installation).
- What happens when the target agent is Codex and the translation produced by the agent is inconsistent or incorrect? Documented as a known risk of ADR-002, mitigated only by documenting Codex support as best-effort; no further resolution is specified.

## Requirements (mandatory)

### Functional Requirements

- FR-001: The installer MUST be a plain-text/natural-language instructions file (`setup-ai.md`) that the target AI agent reads and executes with its own tools, not a bash script or an npx package (ADR-001).
- FR-002: The installer MUST support a "one-liner" install method: a single command pasted in the terminal, or asked of the agent, inside the target repo.
- FR-003: The installer MUST support a "copy-paste" install method: a plain-text block pasted directly into the conversation of any AI coding agent, with no script execution, interpreted and executed by the agent itself.
- FR-004: The installer MUST always ask the user which target agent to install for (Claude Code or Codex CLI) explicitly, rather than inferring it from folders already present in the target repo (ADR-004).
- FR-005: The installer MUST always ask the user which profile to install when more than one profile exists and none was specified, defaulting to `default` otherwise.
- FR-006: The installer MUST fetch the manifest via GET to `raw.githubusercontent.com/<org>/my-aisy-toolkit/main/catalog.yaml`.
- FR-007: The installer MUST fetch each skill/agent file individually via GET to `raw.githubusercontent.com/.../main/ai-toolkit/default/commands|agents/*.md`, one request per file, with no caching.
- FR-008: When the target agent is Claude Code, the installer MUST write the fetched files unmodified into `.claude/` in the target repo, matching their `ai-toolkit/default/` source.
- FR-009: When the target agent is Codex CLI, the installer MUST translate each fetched skill/agent into `.codex/skills/*/SKILL.md` format at install time, performed by the agent's own interpretation rather than a pre-generated catalog or external service (ADR-002).
- FR-010: The installer's side effects MUST be limited to writing/overwriting files inside `.claude/` and/or `.codex/` in the target repo; it MUST NOT touch application code or other folders.
- FR-011: If the manifest fetch returns 404 or is unreachable, the installer MUST abort the installation and inform the user, writing nothing.
- FR-012: If a skill/agent file fetch returns 404 or times out, the installer MUST retry once; if it still fails, it MUST inform the user and skip that file without blocking installation of the remaining files.
- FR-013: If a target repo file already exists with content different from the source, the installer MUST overwrite it (always-latest-version principle; no semantic versioning).
- FR-014: If the user does not confirm whether the target is Claude Code or Codex CLI, the installer MUST ask again and MUST NOT write any file until answered.
- FR-015: On re-installation/update, the installer MUST always install the latest catalog version, add any new skills/agents not yet present, and update any that have changed.
- FR-016: The installer MUST work without invoking or requiring the target repo to have any pre-existing dependency (zero-dependencies goal underlying ADR-001), on any OS/agent capable of reading instructions and fetching URLs.
- FR-017: The one-liner MUST be the single-line natural-language instruction `Fetch and follow the setup instructions at https://raw.githubusercontent.com/charlstown/my-aisy-toolkit/main/setup-ai.md`, usable verbatim both pasted into an agent conversation and quoted as the prompt argument of a CLI invocation (`claude "..."`, `codex "..."`). It MUST NOT be a bash/curl command (ADR-001).
- FR-018: For the one-liner method, the agent MUST bootstrap by performing a GET on the `setup-ai.md` raw URL and following the fetched content. For the copy-paste method, no fetch of `setup-ai.md` occurs — the pasted block is that content. Therefore `setup-ai.md` MUST read correctly standalone (no external "step 0" file, no relative references, absolute URLs only) and MUST instruct the agent never to re-fetch itself.
- FR-019: The installer MUST ask the target-agent question with the wording fixed in `setup-ai.md` Step 1 ("One thing before I touch anything — which agent am I setting this up for? 1. Claude Code / 2. Codex CLI (best-effort support)"), and MUST re-ask with the fixed follow-up wording if unanswered or ambiguous. The profile question ("There's more than one profile in the catalog. Which one do you want?", listing each declared profile with its skill/agent counts) MUST be asked only after the catalog is fetched and only when it declares more than one profile and the user named none; otherwise the single declared profile is used silently.

### Key Entities

- Catalog (`catalog.yaml`): The manifest declaring, per profile, which skill/agent files belong to that profile and where their sources live; fetched once per install run.
- Profile: A named grouping of skills/agents (e.g., `default`) that can be installed independently; a repo's `catalog.yaml` may declare more than one.
- Skill / Agent file: An individual Markdown file (under `ai-toolkit/default/commands|agents/*.md`) representing one installable capability, fetched and written (or translated) into the target repo.
- Target agent: The AI coding agent the install is being performed for (Claude Code or Codex CLI), determining the destination format (`.claude/` native vs. `.codex/skills/*/SKILL.md` translated).

## Success Criteria (mandatory)

### Measurable Outcomes

- SC-001: Running the one-liner install method against a dummy folder with Claude Code as the target results in every file declared in `catalog.yaml` for the `default` profile being installed and matching its `ai-toolkit/default/` source unmodified (Phase 1 gate criterion).
- SC-002: Running the copy-paste install method against a dummy folder with Claude Code as the target produces the same result as SC-001 (Phase 1 gate criterion).
- SC-003: Attempting the same check against Codex CLI at least once produces a documented result (pass or fail), without blocking the Phase 1 gate if it fails (best-effort per ADR-002).
- SC-004: Re-running either install method against a repo with an existing, older installation results in new catalog files being added and changed files being overwritten, with no files outside `.claude/`/`.codex/` modified.

## Assumptions

- The target users are developers who have an AI coding agent (Claude Code or Codex CLI) available and a target repo in which to run the installer.
- The feature's scope is limited to installing/updating the `default` profile's declared files into `.claude/` and/or `.codex/`; it does not cover authoring or validating the catalog contents themselves (that is F1.1/F1.2 per the roadmap).
- The installer depends on F1.2 (per the roadmap dependency table), meaning the catalog (`catalog.yaml`) and the `ai-toolkit/default/` source files it fetches already exist and are correctly published before this feature can function.
- Network access to `raw.githubusercontent.com` is assumed available from the environment running the target AI agent.
- No authentication/credentials are described as required to fetch the manifest or files, implying the repository is public.

## DEFINITION GAP

- [ ] The product-spec text describes the one-liner's `agent` parameter as resolved by "auto-detect", while tech-spec's ADR-004 explicitly overrides this and states the target agent is "always asked" explicitly, never inferred from folders. Which behavior is correct/current, and should product-spec be corrected to match ADR-004?
- [x] ~~What is the literal one-liner command/URL syntax the user pastes into their terminal or asks their agent to run?~~ → `Fetch and follow the setup instructions at https://raw.githubusercontent.com/charlstown/my-aisy-toolkit/main/setup-ai.md` — single line, no colon/line break, so it survives being quoted as a CLI prompt argument (`claude "…"`). Same words as the locked `specs/ui-spec.md` Quick start block. See FR-017.
- [x] ~~How is `setup-ai.md` itself fetched/bootstrapped before it can begin fetching the manifest and other files?~~ → One-liner: the agent GETs the fixed raw URL above. Copy-paste: no fetch at all — the pasted text *is* `setup-ai.md`. Consequence: the file is a single self-contained artifact with a human "How to install" section, an explicit `## Instructions for the agent` boundary telling the agent to start at Step 1 and never re-fetch this file, absolute URLs only, and no external "step 0". See FR-018.
- [x] ~~What is the exact wording/UX of the profile-selection question and the target-agent question?~~ → Fixed verbatim in `setup-ai.md` Step 1 (target agent: always asked, numbered 2-option list, plus a re-ask line for FR-014; profile: asked only after the catalog is read and only when it declares more than one profile and none was named). See FR-019.
- [ ] This feature depends on F1.2 (per the roadmap table) — confirm F1.2's catalog/schema and `ai-toolkit/default/` source layout are finalized and stable before this installer is built against them.
- [ ] The Phase 1 gate criterion references F1.5's automated check as the verification mechanism for this feature — confirm F1.5's scope/interface so this feature's acceptance criteria stay compatible with how it will be tested.
