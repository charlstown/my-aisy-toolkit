---
name: clean-feature
description: Align root specifications with completed feature plans, then archive selected feature folders and close their GitHub issues. Use when the user says clean-feature, cleanup, limpia las carpetas, limpia los specs, alinea los specs, or asks to clean completed specs folders.
---

# Clean feature

Use the user's language. Find `specs/*/plan.md` files with no unchecked tasks; report blocked tasks but do not exclude them. If several qualify, ask which folders to process.

For each selection, read its requirements and plan, inspect its git history, and summarize the delivered behavior. Audit only relevant root specs: product, tech, CSS, UI, infrastructure, security, and roadmap. Make small, evidence-backed edits, including the spec `Updated` date when present. Do not make cosmetic changes.

Before deleting anything, show changed specs and target folders and obtain explicit confirmation. After confirmation, safely delete only those exact folders, verify their absence, and close the linked GitHub issue only when product and tech specs are aligned or updated. Add the implementation summary as the closing comment. Create the requested chore commit and push only if the user explicitly included that authorization. Report skipped or failed issue closures separately.
