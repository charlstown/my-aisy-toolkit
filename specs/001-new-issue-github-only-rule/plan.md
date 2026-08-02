# Plan: Documentar como regla mandatory que new-issue nunca escribe en el repo, solo en GitHub

> [!abstract] Metadata
> | | |
> |---|---|
> | **Status** | 🟡 Draft |
> | **Feature branch** | `001-new-issue-github-only-rule` |
> | **Requirements** | [[requirements]] |
> | **GitHub issue** | #21 |

## 📐 Texto del bloque mandatory (para copiar literal en ambas copias)

> **GitHub-only write scope (mandatory):** this skill's only write permission is GitHub — creating issues via `gh issue create`. It must never create, edit, or delete files in the repository, and it must never run `git commit` or `git push`. Using `Write`, `Edit`, `git commit`, or `git push` on repository files is explicitly forbidden at any point during this skill's execution, in both the Bug Flow and the Feature Flow.

## ✅ Tasks

## Batch 1 — Draft and insert the mandatory block

- [x] @architect · Validate the mandatory block wording: review the exact text proposed above against the existing normative pattern already used in `ai-toolkit/default/commands/new-issue.md` (the blockquote `> **Title convention (mandatory):** ...` at line 15) and against FR-001/FR-003 of `requirements.md`. Confirm the wording (a) states the skill's only write permission is GitHub via `gh issue create`, and (b) explicitly names `Write`, `Edit`, `git commit`, and `git push` as forbidden on repository files. Adjust the wording only if it fails either check; otherwise confirm it as final and hand it to @code-developer verbatim.

- [x] @code-developer · Insert the mandatory block into `ai-toolkit/default/commands/new-issue.md`: add the validated block as the very first content after the YAML frontmatter (before the `## Language` section at line 5), so it is the first `mandatory` block encountered in the file, before any other instruction (FR-001, FR-005). Do not modify the existing `## Language` section, the existing `Title convention (mandatory)` blockquote, or any other content of the file.

- [x] @code-developer · Replicate the same block into `.claude/commands/new-issue.md`: insert the exact same text, byte-for-byte, at the same position (immediately after the frontmatter, before `## Language`) in `.claude/commands/new-issue.md` (FR-002, FR-004). Do not introduce any wording drift between the two copies, and do not touch any other line of either file.

## Batch 2 — Verify synchronization and scope

- [ ] @tester · Diff both copies and confirm compliance: run a diff between `ai-toolkit/default/commands/new-issue.md` and `.claude/commands/new-issue.md` and confirm the only difference between them remains the pre-existing one (the `/specify-feature` vs `/get-issues` reference at the end of the Bug Flow, F6/B6 — unrelated to this change) and that the new mandatory block is byte-identical in both (FR-004). Confirm the block is positioned as the first block in the file, before `## Language` (FR-005), and confirm it explicitly names `Write`, `Edit`, `git commit`, and `git push` as forbidden (FR-003). Report any mismatch back to @code-developer instead of fixing it.

## Batch 3 — Quality gate

- [ ] @judge · Review against acceptance criteria: read both updated files plus `specs/001-new-issue-github-only-rule/requirements.md` and confirm SC-001 (an unambiguous mandatory block restricting writes to GitHub is identifiable in `ai-toolkit/default/commands/new-issue.md`), SC-002 (the same block, with equivalent content, is identifiable in `.claude/commands/new-issue.md`), and SC-003 (the three acceptance criteria of GitHub issue #21 are satisfied: explicit mandatory block in both files; explicit prohibition of `Write`/`Edit`/`git commit`/`git push`; both copies synchronized). Emit PASS or CHANGES_REQUESTED; if CHANGES_REQUESTED, route the specific gap back to @architect (wording) or @code-developer (placement/sync) as appropriate.

### Critical Files for Implementation
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\ai-toolkit\default\commands\new-issue.md
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\.claude\commands\new-issue.md
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\specs\001-new-issue-github-only-rule\requirements.md

## Nota

FR-006 (propagar el bloque mandatory a la copia externa en el Vault del usuario, bajo `setup-ai/templates`) queda **excluida de este plan** por decisión explícita del usuario durante la planificación (2026-08-02): se pospone para una conversación futura cuando tenga la ruta absoluta a mano. No generar ninguna tarea para esa copia externa.
