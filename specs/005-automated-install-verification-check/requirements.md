# Automated install verification check
Feature Branch: 005-automated-install-verification-check

Created: 2026-08-01

Status: Draft

Input: User description: "specs\roadmap.md"

## User Scenarios & Testing (mandatory)

### User Story 1 - Verify a fresh install matches the catalog unmodified (Priority: P1)

As the maintainer of my-aisy-toolkit, before closing Phase 1 of the roadmap, I need a check that installs the `default` profile into a dummy/scratch folder using both supported install methods (one-liner and copy-paste), with Claude Code as the target agent, and then confirms that every file declared in `catalog.yaml` for the `default` profile was actually installed and matches its source in `ai-toolkit/default/` unmodified. This is the evidence required to satisfy the Phase 1 Gate Final Milestone in `specs/roadmap.md`.

Why this priority: This is the sole reason the feature exists — it is a named, verbatim closing criterion for the Phase 1 gate ("Installable default profile"). Without it, the gate cannot be declared met. There is no lower-priority variant of this story in the source material.

Independent Test: Can be fully tested by running the check against a dummy/scratch folder with Claude Code as the target — using each install method in turn — and confirming the check reports every catalog-declared file present and unmodified. Delivers the Phase 1 gate evidence on its own, independent of any other feature.

Acceptance Scenarios:

1. Given a dummy/scratch folder with no prior installation, When the check runs the one-liner install method targeting Claude Code, Then every file declared in `catalog.yaml` for the `default` profile is present in the target folder and byte-for-byte/content-equivalent to its source under `ai-toolkit/default/` [NEEDS CLARIFICATION: exact equivalence criterion — see DEFINITION GAP].
2. Given a dummy/scratch folder with no prior installation, When the check runs the copy-paste install method targeting Claude Code, Then every file declared in `catalog.yaml` for the `default` profile is present in the target folder and matches its source under `ai-toolkit/default/` unmodified.
3. Given the check has been run against Claude Code with both install methods, When the same check is attempted against Codex CLI at least once, Then the result (pass or fail) is documented, and a failure against Codex CLI does not block the Phase 1 gate (best-effort per ADR-002).

## Edge Cases

- What happens when a file declared in `catalog.yaml` for the `default` profile is missing from the target folder after install?
- What happens when a file is present in the target folder but its content differs from `ai-toolkit/default/` (partial or full modification)?
- How does the check handle a target folder that is not empty / already contains a prior installation (dummy folder reuse)?
- How does the check behave differently between Claude Code (required, blocking) and Codex CLI (best-effort, non-blocking) when a file mismatch or install failure occurs?
- What happens if the one-liner and copy-paste install methods produce different results against the same target for the same profile?
- The user's own description of this gate uses the word "launched" ("comprobacion de que se han lanzado ... los documentos") alongside "copied unmodified." Skills/agent files are not executed at install time — only written to disk (per tech-spec.md Healthcheck: "There is no running process or endpoint to query"). It is unclear whether "launched" is meant loosely (i.e., synonymous with "installed/copied") or implies some distinct runtime/activation check — see DEFINITION GAP.

## Requirements (mandatory)

### Functional Requirements

- FR-001: The check MUST perform an installation of the `default` profile into a dummy/scratch folder (not the toolkit repo itself, not a real target repo already in use).
- FR-002: The check MUST run the installation using both install methods described elsewhere in the toolkit (one-liner and copy-paste) against Claude Code as the target agent.
- FR-003: The check MUST, for each install method run, enumerate every file declared in `catalog.yaml` for the `default` profile and confirm each one exists in the installed target location.
- FR-004: The check MUST confirm that each installed file matches its corresponding source file under `ai-toolkit/default/` unmodified [NEEDS CLARIFICATION: exact comparison method not specified — e.g. byte-identical diff, content hash, or something else].
- FR-005: The check MUST also be attempted, at least once, against Codex CLI as an alternate target.
- FR-006: The check's result against Codex CLI MUST be documented, regardless of pass or fail.
- FR-007: A failing result against Codex CLI MUST NOT block the Phase 1 gate from being declared met (best-effort per ADR-002), whereas the source material implies the Claude Code result IS required for the gate (this asymmetry is stated for Codex CLI only; the source does not explicitly confirm Claude Code's result is blocking, though it is the primary criterion named in the gate — see DEFINITION GAP).
- FR-008: System MUST produce a way to determine pass/fail per file and, in aggregate, per install method/target combination [NEEDS CLARIFICATION: no specified output format, report location, or pass/fail aggregation rule].

### Key Entities

- Dummy/scratch folder: A disposable target directory, distinct from the toolkit repo and from any real consuming repo, into which the `default` profile is installed for verification purposes only.
- Catalog entry (`catalog.yaml`, `default` profile): Declares the set of files belonging to the `default` profile and (per feature F1.3, not detailed here) presumably their source and destination paths, used as the ground truth the check verifies against.
- Install method: One of two documented ways to install the toolkit — "one-liner" and "copy-paste" — each of which the check must exercise.
- Target agent: The agent an installation is verified against; Claude Code (required) and Codex CLI (best-effort, attempted at least once).

## Success Criteria (mandatory)

### Measurable Outcomes

- SC-001: The check runs to completion against a dummy/scratch folder using the one-liner install method with Claude Code as the target, and reports whether every `catalog.yaml`-declared `default`-profile file was installed and matches its `ai-toolkit/default/` source unmodified.
- SC-002: The check runs to completion against a dummy/scratch folder using the copy-paste install method with Claude Code as the target, and reports the same confirmation as SC-001.
- SC-003: The check is attempted at least once against Codex CLI, and its pass/fail result is documented (in whatever form — see DEFINITION GAP) without being required to pass.
- SC-004: The Phase 1 Gate Final Milestone in `specs/roadmap.md` can be marked satisfied once SC-001, SC-002, and SC-003 have been evidenced.

## Assumptions

- The `default` profile and its `catalog.yaml` declaration (file list, sources, destinations) already exist and are correct, as delivered by feature F1.3 ("Depends on: F1.3"), which this feature depends on and does not redefine.
- The one-liner and copy-paste install methods referenced here are the same two methods already defined elsewhere in the toolkit (per F1.3/setup-ai.md) and are not being newly specified by this feature.
- "Claude Code" and "Codex CLI" refer to the same two target agents already referenced throughout `tech-spec.md` and `roadmap.md`; no new target agents are in scope.
- The dummy/scratch folder is disposable and separate from any real project; nothing about persisting or reusing it across runs is specified.

## DEFINITION GAP

- [ ] **Manual vs. automated testing conflict**: `tech-spec.md`'s Testing Strategy section states there is currently "no automated tooling" and that verification is manual ("Prueba manual en un repo de scratch" was the explicit decision made during the tech-spec interview, chosen over "Sin validación formal"), and Known Limitations reiterates "No automated tests or CI/CD: validation is manual, in a scratch repo, before publishing changes to main." Yet the Phase 1 gate in `roadmap.md` requires an "automated check." These two source documents are not reconciled. Does F1.5 mean building new automated tooling (e.g., a script) that supersedes the tech-spec's manual-only testing strategy, or does "automated" in the roadmap actually describe the same manual-but-repeatable procedure already described in tech-spec.md, and the wording should be reconciled instead? This must be resolved before F1.5 can be planned or implemented.
- [ ] What actually runs the check — a script, a prompt/skill an agent follows, a CI job, or a manual procedure performed by Carlos? The source material does not say who or what triggers it.
- [ ] What does "matches unmodified" precisely mean — byte-identical file comparison, a content hash comparison, or some other equivalence check?
- [ ] What does "launched" mean in the user's own description of this gate ("se han lanzado, y copiado los documentos")? Skill/agent files are written at install time but are not executed/run then (per tech-spec.md Healthcheck, "There is no running process or endpoint to query"). Is "launched" just loose phrasing for "installed," or does it imply some additional activation/runtime check not otherwise described?
- [ ] Is a failing result against Claude Code (as opposed to Codex CLI) blocking for the Phase 1 gate? The source states the Codex CLI result is explicitly non-blocking/best-effort; it does not explicitly state the consequence of a Claude Code failure, though the gate's primary criterion is framed around Claude Code as the required target.
- [ ] What output or report format is expected from the check (pass/fail log, file-by-file diff report, a markdown summary, console output only, etc.), and where should it be stored or documented?
- [ ] Dependency confirmation: this feature depends on F1.3 (catalog.yaml manifest / installer) being complete and stable before the check can be meaningfully run — has F1.3 been completed and is its `catalog.yaml` schema considered final?
