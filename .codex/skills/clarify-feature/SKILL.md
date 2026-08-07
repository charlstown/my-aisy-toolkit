---
name: clarify-feature
description: Resolve only the documented open decision gaps in feature requirements. Use when the user says clarify-feature, clarifica, cierra los gaps, resuelve los gaps, or asks to close the open items in specs/*/requirements.md.
---

# Clarify feature

Use the user's language throughout. Locate the target `requirements.md` from a path, feature slug, or the files under `specs/*/requirements.md`. Treat a gap section as any level-2 heading containing "gap" with unchecked `- [ ]` items.

If several files have open gaps, ask the user which file, or whether to process all sequentially. For each file, ask only about its existing unchecked items, at most four questions per round. Offer concrete contextual choices and an explicit "decide later" choice.

Fold each explicit decision into the relevant requirement, assumption, or edge case and remove its clarification marker. Do not invent answers, discover new gaps, widen scope, or rewrite unrelated text. Retain deferred items; remove the gap section only when it becomes empty.

Finish with a compact table: feature, gaps resolved, and gaps still open.
