---
name: constitution
description: Bootstrap the foundational product specification, technical specification, and roadmap in dependency order. Use when the user says constitution, constitución, funda el proyecto, bootstrap specs, crea la constitución del proyecto, or asks to create the project foundation specs.
---

# Project constitution

Use the user's language. Check for `specs/product-spec.md`, `specs/tech-spec.md`, and `specs/roadmap.md`. If any exists, ask whether to regenerate all, create only missing documents, or cancel.

Run the related skills sequentially: `$product-spec`, then `$tech-spec`, then `$roadmap`. Wait until each file is complete before beginning the next, since each later document depends on the earlier ones. Skip retained files when the user chose "only missing". End by confirming the files created or updated.
