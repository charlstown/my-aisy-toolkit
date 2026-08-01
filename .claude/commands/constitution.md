---
description: Bootstraps a project's foundational specs in one motion — runs `product-spec` first to establish the what/why, then `tech-spec` once it's finished (tech-spec's own Phase 0 already reads the freshly written specs/product-spec.md). Trigger when the user says "constitution", "constitución", "funda el proyecto", "bootstrap specs", "crea la constitución del proyecto", or invokes /constitution.
---

## Language

Detect the language of the user's initial (or most recent) message and conduct the ENTIRE interaction in that language — every `AskUserQuestion` prompt, header, option label and description, and every message, summary, and generated file or output. Mirror the user's language exactly and never switch to another language. These instructions are written in English, but that must NOT force the interaction into English: if the user wrote in Spanish, ask and write in Spanish; if they wrote in another language, use that one. The language of the inputs determines the language of the outputs.

## Purpose

A project's "constitution" is its pair of root specs: `specs/product-spec.md` (the what and the why) and `specs/tech-spec.md` (the how). This skill is a thin orchestrator — it does not interview the user itself. It simply runs `product-spec` to completion, then runs `tech-spec` to completion, in that fixed order, because `tech-spec`'s own Phase 0 reads `specs/product-spec.md` to condition its technical questions. Running them out of order (or in parallel) defeats that.

## Instructions

### Step 0 — Check what already exists

Use `Glob` to check for `specs/product-spec.md` and `specs/tech-spec.md`.

| product-spec.md | tech-spec.md | Action |
|---|---|---|
| Missing | Missing | Go straight to Step 1 (run both, no question needed) |
| Exists | Missing | Ask (see below) — likely just needs Step 2 |
| Missing | Exists | Ask (see below) — unusual; likely tech-spec is stale or hand-written |
| Exists | Exists | Ask (see below) — likely a re-run |

If **either file already exists**, use `AskUserQuestion`:

- Question: "product-spec.md and/or tech-spec.md already exist. What do you want to do?"
- Options:
  - `Regenerate both from scratch` — description: "Re-run product-spec and then tech-spec, updating both files"
  - `Only run what's missing` — description: "Skip any spec that already exists and only generate the missing one(s)"
  - `Cancel` — description: "Don't touch the existing specs"

If the user cancels, stop here.

If **only what's missing** was chosen and both files already exist, tell the user there is nothing to bootstrap and stop — point them to `/product-spec` or `/tech-spec` directly if they want to update an existing one, or to `/clean-feature` if the specs are just out of sync with completed work.

### Step 1 — Run `product-spec`

Unless Step 0 determined `specs/product-spec.md` already exists and should be kept as-is, run the `product-spec` skill now, in full — its own interview, its own file write. Wait for it to completely finish and confirm `specs/product-spec.md` was written before moving on.

### Step 2 — Run `tech-spec`

Run the `tech-spec` skill now, in full. Its Phase 0 will read the `specs/product-spec.md` written (or already present) from Step 1 on its own — do not pass it manually, and do not summarize product-spec's content into the tech-spec prompt yourself. Wait for it to completely finish and confirm `specs/tech-spec.md` was written.

### Step 3 — Summary

Once both are done, tell the user:

```
✓ specs/product-spec.md
✓ specs/tech-spec.md

Next: /roadmap to turn these into an execution plan.
```

## Constraints

- **Strictly sequential.** Never run `product-spec` and `tech-spec` in parallel — `tech-spec` depends on reading the finished `product-spec.md`.
- **No interview of its own.** All questions come from within `product-spec` and `tech-spec`; this skill only decides whether to run them and in what order.
- **Do not skip Step 0's check.** Silently overwriting an existing product-spec.md or tech-spec.md without asking risks discarding decisions already recorded in them.
