---
name: roadmap
description: Generate or update a phased execution roadmap from the ProductSpec and TechSpec. Use when the user says roadmap, genera roadmap, create roadmap, planifica el roadmap, or asks for specs/roadmap.md.
---

# Roadmap

Use the user's language. Read `specs/product-spec.md`, `specs/tech-spec.md`, any existing roadmap, and README. Identify deliverables, technical dependencies, explicit exclusions, closing gates, and any proof-of-concept hypotheses. Ask a short focused interview only for sequencing or scope decisions that cannot be inferred.

Write `specs/roadmap.md` with Metadata, Tracking, Vision, Overview, ordered Phases, Dependency Graph, Gates, and Out of Roadmap. Add Phase 0 only when the TechSpec defines real PoCs. Keep it an execution-order document: do not repeat product vision or technical-stack detail. Make acceptance criteria and dependencies explicit, preserve completed work, and mark unresolved items clearly.
