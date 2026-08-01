# Plan: Populate ai-toolkit/default/ catalog

> [!tip] Corrected context (2026-08-01) — supersedes the earlier "vault-only, 9 skills, 0 agents" scope note
> The earlier draft of this plan inventoried the wrong path (`D:\MisProyectos\0_TEMPLATES\AI\SKILLS`, a 9-folder Spanish-language set with no agents). The maintainer has now confirmed the correct source vault is **`D:\MisProyectos\0_TEMPLATES\SETUP-AI`**, which contains:
> - `agents/` — 6 files: `architect.md`, `code-developer.md`, `judge.md`, `test-developer.md`, `tester.md`, `ui-developer.md`.
> - `skills/` — 13 folders: `constitution`, `product-spec`, `tech-spec`, `roadmap`, `get-issues`, `new-issue`, `specify-feature`, `clarify-feature`, `grill-me`, `plan-feature`, `implement-feature`, `clean-feature` (these 12 already match this repo's own `.claude/commands/*.md` one-for-one), plus a 13th folder, `setup-ai`, not yet present in this repo's `.claude/commands/`.
>
> This matches `specs/product-spec.md`'s Interfaces catalog table (12 skills + 6 agents) — **the cross-spec inconsistency flagged in the earlier draft (against 002/003/004/005, which all assume 12+6) no longer applies** once sourcing from the correct vault. Batch 1 still starts with a fresh inventory (this time of the correct path) so Batch 2 works from a verified list rather than from this note alone, and to resolve whether the 13th `setup-ai` skill belongs in this population run (it looks like a generic "install this toolkit" skill, distinct from the root `setup-ai.md` file that feature 003/`specs/003-setup-ai-installer` is authoring for *this* repo).

## Batch 1 — Inventory the vault as the source of truth

- [x] @architect · Inventory the correct vault and resolve the `setup-ai` skill question: recursively list every file under `D:\MisProyectos\0_TEMPLATES\SETUP-AI\agents` and `D:\MisProyectos\0_TEMPLATES\SETUP-AI\skills`, confirming the 6 agent files and the 13 skill folders (each expected to hold a `SKILL.md` or equivalent — check the actual filename used). Cross-check the 12 non-`setup-ai` skill names and the 6 agent names against this repo's own `.claude/commands/*.md` and `.claude/agents/*.md` (should match one-for-one). Decide whether the 13th skill, `setup-ai`, should be copied into `ai-toolkit/default/commands/setup-ai.md` as part of this population run: read its content first — if it is a generic "fetch and install this toolkit" skill that would duplicate or conflict with the root `setup-ai.md` file `specs/003-setup-ai-installer` is building, exclude it and note why; otherwise include it as a 13th command and flag the count change (12 → 13) for `specs/product-spec.md`'s catalog table to be updated separately. Produce the definitive list of {folder/file name, main file, language, completeness} that Batch 2 will copy from.

## Batch 2 — Populate the catalog from the vault

- [x] @code-developer · Create `ai-toolkit/default/commands/` and `ai-toolkit/default/agents/`: create both folders (the repo currently has no `ai-toolkit/` directory at all).
- [x] @code-developer · Copy the vault's skills and agents as-is: for each skill folder and agent file confirmed in Batch 1 (the 12, or 13 if Batch 1 decided to include `setup-ai`, plus the 6 agents), copy its content into `ai-toolkit/default/commands/<name>.md` and `ai-toolkit/default/agents/<name>.md` respectively, preserving content and frontmatter exactly as found in the vault (no translation, no content invention).
- [x] @code-developer · Scan for vault-specific leakage: grep the copied files for references to the vault's own environment (absolute paths like `D:\MisProyectos\...`, other project names, or artifacts specific to the maintainer's local setup) that would not make sense once installed into an arbitrary end-user target repo. Generalize or remove any such reference; do not rewrite behavior otherwise.

## Batch 3 — Validate

- [ ] @code-developer · Validate frontmatter on all copied files: parse the YAML frontmatter block of every file in `ai-toolkit/default/commands/` and `ai-toolkit/default/agents/` and confirm each has a usable description/name field, matching the schema already used by this repo's own `.claude/commands/*.md` and `.claude/agents/*.md`; note any mismatch found.
- [ ] @judge · Final consistency review: verify `ai-toolkit/default/commands/` contains exactly the skills confirmed in Batch 1 (12, or 13 if `setup-ai` was included — no extras, no omissions) and `ai-toolkit/default/agents/` contains exactly the 6 agents; confirm no file has malformed frontmatter; confirm the file contents match the vault byte-for-byte modulo the leakage cleanup from Batch 2. If the skill count differs from `specs/product-spec.md`'s documented 12, explicitly flag that product-spec.md's catalog table needs a follow-up update (separate from this plan). Report PASS or CHANGES_REQUESTED.

### Critical Files for Implementation
- D:\MisProyectos\0_TEMPLATES\SETUP-AI\agents\*.md (6 source agent files — corrected vault path)
- D:\MisProyectos\0_TEMPLATES\SETUP-AI\skills\*\ (13 source skill folders — corrected vault path)
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\.claude\commands\*.md (this repo's own 12 skills, for cross-check)
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\.claude\agents\*.md (this repo's own 6 agents, for cross-check)
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\specs\tech-spec.md (ADR-005, Known Limitations re: vault sync)
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\specs\roadmap.md (F1.1 scope and dependency graph)
