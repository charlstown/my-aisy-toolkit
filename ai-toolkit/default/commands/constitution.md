---
description: Bootstraps a project's foundational specs in one motion — runs `product-spec` first to establish the what/why, then `tech-spec` once it's finished (tech-spec's own Phase 0 already reads the freshly written specs/product-spec.md). Trigger when the user says "constitution", "constitución", "funda el proyecto", "bootstrap specs", "crea la constitución del proyecto", or invokes /constitution.
---

## Language

Detect the language of the user's initial (or most recent) message and conduct the ENTIRE interaction in that language — every `AskUserQuestion` prompt, header, option label and description, and every message, summary, and generated file or output. Mirror the user's language exactly and never switch to another language. These instructions are written in English, but that must NOT force the interaction into English: if the user wrote in Spanish, ask and write in Spanish; if they wrote in another language, use that one. The language of the inputs determines the language of the outputs.

## Purpose

A project's "constitution" is its pair of root specs: `specs/product-spec.md` (the what and the why) and `specs/tech-spec.md` (the how). This skill is a thin orchestrator — it does not interview the user itself. It simply runs `product-spec` to completion, then runs `tech-spec` to completion, in that fixed order, because `tech-spec`'s own Phase 0 reads `specs/product-spec.md` to condition its technical questions. Running them out of order (or in parallel) defeats that.

## Instructions

### Step 0 — Check what already exists

Use `Glob` to check for `specs/product-spec.md`, `specs/tech-spec.md`, and `specs/roadmap.md`.

| product-spec.md | tech-spec.md | roadmap.md | Action |
|---|---|---|---|
| Missing | Missing | Missing | Go straight to Step 1 (run all three, no question needed) |
| Exists | Missing | Missing | Ask (see below) — likely just needs Step 2 |
| Missing | Exists | Missing | Ask (see below) — unusual; likely tech-spec is stale or hand-written |
| Missing | Missing | Exists | Ask (see below) — unusual; likely roadmap is stale or hand-written |
| Exists | Exists | Missing | Ask (see below) — likely just needs Step 3 |
| Exists | Missing | Exists | Ask (see below) — unusual; likely tech-spec is missing or stale while roadmap exists |
| Missing | Exists | Exists | Ask (see below) — unusual; likely product-spec is missing or stale while the others exist |
| Exists | Exists | Exists | Ask (see below) — likely a re-run |

If **any file already exists**, use `AskUserQuestion`:

- Question: "product-spec.md, tech-spec.md and/or roadmap.md already exist. What do you want to do?"
- Options:
  - `Regenerate all from scratch` — description: "Re-run product-spec, tech-spec, and roadmap in order, updating all three files"
  - `Only run what's missing` — description: "Skip any of product-spec, tech-spec, or roadmap that already exists and only generate the missing one(s)"
  - `Cancel` — description: "Don't touch the existing specs"

If the user cancels, stop here.

If **only what's missing** was chosen and all three files already exist, tell the user there is nothing to bootstrap and stop — point them to `/product-spec`, `/tech-spec`, or `/roadmap` directly if they want to update an existing one, or to `/clean-feature` if the specs are just out of sync with completed work.

When **only what's missing** is chosen and at least one file is missing, run only the Steps whose corresponding file is absent, in strict order (Step 1 → product-spec, Step 2 → tech-spec, Step 3 → roadmap), skipping any Step whose file already exists. For example, if only `specs/roadmap.md` is missing, skip straight to Step 3 without re-running Steps 1 or 2.

### Step 1 — Run `product-spec`

Unless Step 0 determined `specs/product-spec.md` already exists and should be kept as-is, run the `product-spec` skill now, in full — its own interview, its own file write. Wait for it to completely finish and confirm `specs/product-spec.md` was written before moving on.

### Step 2 — Run `tech-spec`

Run the `tech-spec` skill now, in full. Its Phase 0 will read the `specs/product-spec.md` written (or already present) from Step 1 on its own — do not pass it manually, and do not summarize product-spec's content into the tech-spec prompt yourself. Wait for it to completely finish and confirm `specs/tech-spec.md` was written.

### Step 3 — Summary

Show this block only when the run finished successfully, meaning Steps 1 and 2 both ran and both spec files were confirmed written. If the run ended any other way (the user picked `Cancel` in Step 0, or Step 0 ended with nothing to bootstrap), show nothing: no block, no next step line.

Then close with:

```
✓ specs/product-spec.md
✓ specs/tech-spec.md

✅ Done. Suggested next step:

🗺️ /roadmap (optional) to turn the specs into a phased plan. Skip it if you already know what comes first.
🎯 /specify-feature to turn what you want to build next into a feature spec.
```

Write the block in the user's language, following the `## Language` section at the top of this file. Keep the skill names (`/roadmap`, `/specify-feature`) and the emojis exactly as they are, only the words around them get translated.

This block only suggests. Do not run the suggested skill yourself and do not chain into it: stop here and wait for the user to invoke it.

## Constraints

- **Strictly sequential.** Never run `product-spec` and `tech-spec` in parallel — `tech-spec` depends on reading the finished `product-spec.md`.
- **No interview of its own.** All questions come from within `product-spec` and `tech-spec`; this skill only decides whether to run them and in what order.
- **Do not skip Step 0's check.** Silently overwriting an existing product-spec.md or tech-spec.md without asking risks discarding decisions already recorded in them.
