# Plan — catalog.yaml manifest

Requirements: specs/002-catalog-yaml-manifest/requirements.md
Feature Branch: 002-catalog-yaml-manifest

## Context gathered

- `ai-toolkit/default/` does not exist yet in this repo — feature 002 depends on feature 001 (`Populate ai-toolkit/default/ catalog`), which is still unimplemented. `catalog.yaml`'s source paths must point at `ai-toolkit/default/commands/*.md` and `ai-toolkit/default/agents/*.md`, mirroring the 12 skill + 6 agent names already used internally at `.claude/commands/*.md` and `.claude/agents/*.md`.
- Resolved schema (per clarification): `profiles.<name>.commands: [...]` and `profiles.<name>.agents: [...]`, flat lists of source paths, no destination-path translation encoded (that's a runtime concern of `setup-ai`/ADR-002).
- tech-spec.md ADR-003 / roadmap.md F1.2 confirm scope: a single `catalog.yaml` at repo root, no automated validation tooling required (drift-detection stays manual per tech-spec's Known Limitations and Testing Strategy — out of scope for this plan beyond documenting the manual check).

## Batch 1 — Confirm schema and file inventory

- [x] @architect · Confirm catalog.yaml schema and the exact 18 source paths: Read `specs/product-spec.md` (Interfaces → Catalog — `default` profile) and `specs/001-populate-ai-toolkit-default-catalog/requirements.md` (FR-001, FR-002) to derive the authoritative list of the 12 skill filenames and 6 agent filenames for the `default` profile. Cross-check against this repo's own `.claude/commands/*.md` and `.claude/agents/*.md` (same names, since `ai-toolkit/default/` is expected to mirror that naming once F1.1 is populated — verify with `Glob` whether `ai-toolkit/default/commands/` and `ai-toolkit/default/agents/` already exist; if not yet populated, proceed using the `.claude/` names as the assumed filenames, flagging this assumption explicitly). Finalize the exact YAML shape to use in Batch 2: a top-level `profiles:` map, with `profiles.default.commands:` as a flat list of `ai-toolkit/default/commands/<name>.md` paths and `profiles.default.agents:` as a flat list of `ai-toolkit/default/agents/<name>.md` paths — per the resolved clarification (no per-target-agent destination paths, no nested per-item objects). Document the confirmed list of 18 source paths for the next task to consume directly.

## Batch 2 — Author catalog.yaml

- [x] @code-developer · Create `catalog.yaml` at the repository root: author `catalog.yaml` in `D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\catalog.yaml` using the schema and the 18 source paths confirmed in Batch 1. Structure:
  ```yaml
  profiles:
    default:
      commands:
        - ai-toolkit/default/commands/constitution.md
        - ai-toolkit/default/commands/product-spec.md
        - ai-toolkit/default/commands/tech-spec.md
        - ai-toolkit/default/commands/roadmap.md
        - ai-toolkit/default/commands/get-issues.md
        - ai-toolkit/default/commands/new-issue.md
        - ai-toolkit/default/commands/specify-feature.md
        - ai-toolkit/default/commands/clarify-feature.md
        - ai-toolkit/default/commands/grill-me.md
        - ai-toolkit/default/commands/plan-feature.md
        - ai-toolkit/default/commands/implement-feature.md
        - ai-toolkit/default/commands/clean-feature.md
      agents:
        - ai-toolkit/default/agents/architect.md
        - ai-toolkit/default/agents/code-developer.md
        - ai-toolkit/default/agents/test-developer.md
        - ai-toolkit/default/agents/tester.md
        - ai-toolkit/default/agents/ui-developer.md
        - ai-toolkit/default/agents/judge.md
  ```
  Ensure all 12 command paths and 6 agent paths are present (18 total), the file is valid UTF-8 YAML with no tabs, and the keys/indentation exactly follow the `profiles.<name>.commands` / `profiles.<name>.agents` shape (no extra nesting per entry, no destination-path fields). Do not create or modify any file under `ai-toolkit/default/` itself — that population is feature 001's responsibility; this task only writes the manifest.

## Batch 3 — Validate the manifest

- [x] @judge · Validate catalog.yaml completeness, schema, and consistency: parse `catalog.yaml` (e.g. via a YAML parser or careful manual read) and confirm it loads without errors. Verify that `profiles.default.commands` contains exactly the 12 skill paths and `profiles.default.agents` contains exactly the 6 agent paths listed in `specs/product-spec.md`'s Interfaces catalog table and in `specs/001-populate-ai-toolkit-default-catalog/requirements.md` FR-001/FR-002 (18 entries total, one source path each, no duplicates, no omissions). Confirm the schema is keyed by profile name (`profiles.default...`) rather than by folder structure, so a hypothetical second profile could be added as a sibling key under `profiles` without altering the `default` entry (SC-004). Confirm no per-target-agent destination paths or Codex-specific fields were added (per the resolved clarification — that belongs to the installer, not the manifest). Report PASS if all checks hold, or CHANGES_REQUESTED with the specific missing/incorrect entries otherwise.

### Critical Files for Implementation

- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\catalog.yaml (new — the deliverable)
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\specs\product-spec.md (source of truth for the 12 skills + 6 agents list)
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\specs\001-populate-ai-toolkit-default-catalog\requirements.md (source of truth for exact filenames, FR-001/FR-002)
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\specs\tech-spec.md (ADR-003, schema rationale, Known Limitations on manifest drift)
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\specs\002-catalog-yaml-manifest\requirements.md (this feature's requirements, with resolved clarifications)
