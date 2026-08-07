---
name: plan-feature
description: Turn a feature requirements document into a concrete, agent-attributed implementation plan. Use when the user says plan-feature, genera el plan, planifica esta feature, crea el plan.md, or asks to plan a requirements.md file.
---

# Plan feature

Use the user's language. Resolve the target from an explicit path or select among `specs/*/requirements.md`. Read it and ask no more than three questions, only for critical gaps that cannot be settled from code and project conventions. Do not edit the requirements document.

Inspect the repository, relevant specifications, and available agent roles or instructions. Create or update the sibling `plan.md` with ordered, independently verifiable tasks. Attribute each task to the best fitting `@agent` if the repository defines agents. Include dependencies, files or modules expected to change, acceptance checks, and explicit blockers. Prefer small tasks and do not invent requirements.
