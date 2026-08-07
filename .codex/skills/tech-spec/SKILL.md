---
name: tech-spec
description: Create or update specs/tech-spec.md from repository evidence and a technical decision interview. Use when the user says tech spec, genera techspec, create tech spec, or asks for a TechSpec covering stack, architecture, data, integrations, and operations.
---

# Tech spec

Use the user's language. Read existing specs, manifests, schemas, source layout, and deployment or CI configuration first. Separate verified facts from decisions that need user input. Interview only about the technical how: scope boundaries, exact stack versions, architecture, data and integrations, operations, and tradeoffs. Never invent versions; take them from configuration or mark them TBD.

Write `specs/tech-spec.md` with only applicable sections, in this order: Metadata, Scope, Tech Stack, Module Design, Database Schema, Integration Mapping, Error Handling, Healthcheck, Logging, Testing Strategy, Deployment, Dependencies, ADRs, Known Limitations, Discovery. Use Mermaid for diagrams. Keep module responsibilities to one sentence, do not repeat the ProductSpec's what or why, and identify unresolved decisions explicitly.
