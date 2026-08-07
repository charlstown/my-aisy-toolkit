---
name: specify-feature
description: Turn feature descriptions from files, URLs, roadmaps, GitHub issues, or free text into numbered requirements folders. Use when the user says specify-feature, especifica, define los requirements, or asks to create feature requirements.
---

# Specify feature

Use the user's language. Detect feature input in this order: explicit file, URL, or text; `specs/roadmap.md`; then open GitHub issues if available. Extract one or more feature candidates, excluding clearly completed roadmap entries. Let the user select candidates when more than one is found.

Create the next numbered `specs/<nnn>-<slug>/requirements.md` for each selection. Capture source links, scope, user stories, functional requirements, edge cases, assumptions, non-goals, and acceptance criteria from the evidence. Do not interview the user to resolve ambiguity and do not invent details. Instead, preserve every material unknown as an unchecked item under `## DEFINITION GAP` so `$clarify-feature` can resolve it later.
