---
description: The UI/UX-focused counterpart to `clarify-feature`. Instead of working a pre-itemized gap section, it lets the user pick how many top-down UI/UX questions to run (4, 8, or 12, with one marked as recommended by an analyzed heuristic), interrogates in gated rounds organized like `ui-spec`'s four stages, and folds every answer into the target `requirements.md` using the exact same mechanics `clarify-feature` uses. Trigger when the user says "clarify-uix", "clarifica la UX", "clarify the UI/UX", "resuelve los gaps de UI/UX", or invokes /clarify-uix.
---

## Language

Detect the language of the user's initial (or most recent) message and conduct the ENTIRE interaction in that language — every `AskUserQuestion` prompt, header, option label and description, and every message, summary, and generated file or output. Mirror the user's language exactly and never switch to another language. These instructions are written in English, but that must NOT force the interaction into English: if the user wrote in Spanish, ask and write in Spanish; if they wrote in another language, use that one. The language of the inputs determines the language of the outputs.

## Purpose

Where `clarify-feature` closes gaps that are already itemized under a requirements.md's gap section, `clarify-uix` is its UI/UX-focused counterpart: it doesn't wait for pre-itemized gap bullets — it generates, top-down, a user-chosen number of UI/UX questions (organized across the same four stages `ui-spec` uses: content structure → layout → interaction/states → devices/accessibility), interrogates the user in gated rounds, and folds every answer into the target `requirements.md` using the exact same mechanics `clarify-feature` uses to fold decisions into a document. Unlike `ui-spec` (which produces a dedicated `specs/ui-spec.md` design document), `clarify-uix` never writes to `ui-spec.md` — it only clarifies the `requirements.md` it targets, the same document `clarify-feature` targets.

## Instructions

Follow these steps in order.

### Step 0 — Resolve the target(s)

The user may point at a target in their message: a file path, a folder path, or a feature name/slug.

- **Path to a `requirements.md`** → use it directly.
- **Path to a folder** (e.g. `specs/003-feature-name/`) → use `specs/{folder}/requirements.md`.
- **Feature name or slug fragment** (e.g. "the checkout screen", "003") → `Glob` `specs/*/requirements.md` and match folder names containing the fragment. If more than one matches, list them and ask which one via `AskUserQuestion`.
- **Nothing indicated** → `Glob` `specs/*/requirements.md` to discover every existing feature:
  - **If none found** → tell the user there is no `requirements.md` to clarify, and stop.
  - **If exactly one found** → select it automatically and tell the user which feature was detected.
  - **If more than one found**: print the list as plain text (`{folder}`), then use `AskUserQuestion` (single question, single-select): "Do you want to go through all features one by one, or focus on a specific one?" — options: `All, one by one` (description: "Process every feature in sequence") plus up to 3 individual features as their own options. The rest are reachable via the automatic "Other" option by folder name.

Build **TARGETS**: the single resolved target from any of the first three bullets, or the discovered set from the last one (either all of them, in the order listed, or the single one chosen).

### Step 1 — Process each target sequentially

> Always sequential, never parallel — this step interrogates a human, so each feature's round must finish (and the file must be saved) before the next one starts.

For each target `requirements.md` in **TARGETS**:

#### 1a. Read context

Read in parallel (skip any that don't exist):

- The target `requirements.md`.
- `specs/ui-spec.md` — to know whether prior UI/UX groundwork already exists.

Keep in mind, while reading the target file: existing `[NEEDS CLARIFICATION: ...]` markers, User Scenarios, Functional Requirements, and any gap heading (a `##` heading containing "gap", case-insensitively — covers `## DEFINITION GAP` from `specify-feature` and equivalent variants).

#### 1b. Determine the recommended question count

Compute three signals from what was just read:

| Signal | What it counts |
|---|---|
| **S1 — distinct screens/flows** | Distinct screen, page, view, or flow names referenced anywhere in the target `requirements.md` (User Scenario titles, Key Entities, or Functional Requirement text). The same screen/flow referenced more than once counts once. |
| **S2 — FRs touching UI/UX** | Functional Requirement bullets (`- FR-XXX: ...`) whose text mentions a UI/UX-shaped concern — a screen/page/view name, layout, a component, an interaction (tap/swipe/click/hover), a visual state (empty/loading/error), or an accessibility term. |
| **S3 — prior `ui-spec.md` content** | Whether `specs/ui-spec.md` exists **and** its `## Screens` section already has at least one screen subsection documented. |

Score each signal and sum the points:

| Signal | 0 pts | 1 pt | 2 pts |
|---|---|---|---|
| S1 | 0–1 | 2–3 | ≥4 |
| S2 | 0–2 | 3–5 | ≥6 |
| S3 | no | yes | — |

- **Total 0–1 point** → recommended bucket is **4** (few/no signals).
- **Total 2–3 points** → recommended bucket is **8** (a handful of screens/states).
- **Total 4–5 points** → recommended bucket is **12** (multiple screens/flows, or heavy interaction).

#### 1c. Ask the user how many questions to run

Before building any question, use `AskUserQuestion` — **single question, single-select, exactly 3 fixed options, no free-form number entry**:

- Question: "How many UI/UX questions do you want to run for {folder}?"
- Options, in this order, with `(recommended)` appended to the label of the one the Step 1b heuristic selected:
  - `4 questions` — description: "Quick pass — a handful of high-priority UI/UX decisions."
  - `8 questions` — description: "Standard pass — covers a few screens/states in reasonable depth."
  - `12 questions` — description: "Deep pass — multiple screens/flows or heavy interaction design."

Set **N** to the chosen count (4, 8, or 12).

#### 1d. Build N questions, top-down across `ui-spec`'s four stages

Split N proportionally across the four stages `ui-spec` uses, in this order: **content structure → layout → interaction/states → devices/accessibility**.

- `base = floor(N / 4)` questions per stage.
- Any remainder (`N - 4 × base`) goes to the **interaction/states** stage.

For the fixed options this gives 4→1 per stage, 8→2 per stage, 12→3 per stage (the remainder is 0 in all three, but the rule holds generally).

For each stage, phrase questions top-down and ground them in the target `requirements.md`'s actual content and open markers — do not invent scope beyond what is already implied by its User Scenarios, Functional Requirements, or Edge Cases. Build each question the same way `clarify-feature` does:

- Propose 2-4 plausible options grounded in the document's context (existing requirements, assumptions, entities). The user can always answer via "Other".
- **Always include an explicit "not sure yet / decide later" option.** If the user picks it, that point stays open.

#### 1e. Launch the interrogation in rounds — gated like `ui-spec`

Split the N questions into rounds of **at most 4 per `AskUserQuestion` call**, following stage order. Before the first round, tell the user briefly: how many questions will run for this feature (N) and that you're starting.

**Gate between rounds, the same way `ui-spec` gates between Round 1 and Round 2:** never move to a later stage while an earlier stage's answer leaves a structural ambiguity open. If, while preparing a later round, an earlier stage's answer turns out ambiguous, stop and ask one more targeted follow-up for that earlier stage instead of moving on. Because the total must stay exactly N, that follow-up replaces the least essential remaining question in a later stage rather than adding to the count.

Wait for each round's answers before launching the next. Accumulate as **ANSWERS** (mapping question → answer, including "not sure yet" where chosen).

#### 1f. Fold the answers into the document

Use the exact same mechanics as `clarify-feature`'s Steps 2d/2e. For each answered question:

1. Find where it applies in the document — a `[NEEDS CLARIFICATION: ...]` marker, an ambiguous Edge Case, a missing Assumption, an underspecified Functional Requirement, etc. — and rewrite that part with the decision made, removing the marker.
2. If the question doesn't map to an existing line (it was a standalone question generated in Step 1d), add the decision to the most fitting section (`Assumptions` for scope/dependency decisions, `Functional Requirements` for behavior decisions, `Edge Cases` for edge-case decisions).
3. Do not invent extra detail beyond what the user answered.

For questions left as "not sure yet": if a gap heading already exists in the document, add or keep a bullet for it there, unchanged; if no gap heading exists, leave a `[NEEDS CLARIFICATION: ...]` marker in place instead of resolving that part of the document.

#### 1g. Update or remove any gap section touched

- If every bullet under an existing gap heading was resolved by this run → delete the entire gap heading and its bullets from the file.
- If a gap heading exists and some of its bullets remain open (including newly added "not sure yet" bullets) → keep the heading with only the still-open bullets.
- If the document has no gap heading, leave it as is — `clarify-uix` does not create a gap section on its own.

Write the file with `Edit`/`Write`.

#### 1h. Per-feature confirmation

If processing multiple targets, print a short line before moving on:

```
✓ {folder}: {N} UI/UX question(s) run — {resolved}/{N} folded into the document{" — gap section updated" if a gap section was touched}
```

### Step 2 — Final summary

When all targets are processed, show:

```
## Clarify UI/UX summary

| Feature | Questions run | Folded in | Left open |
|---|---|---|---|
| {folder} | {N} | {resolved} | {open} |
```

If any feature still has items left open ("not sure yet"), remind the user they can run `/clarify-uix` again on that feature once they have an answer.

## Constraints

- **Never invent answers.** Every point folded into the document must trace back to an explicit user answer given in this session.
- **Sequential only.** Do not dispatch parallel subagents for this skill; if several targets are processed, each one's interrogation must finish (and its file be saved) before the next one starts.
- **Exactly N, no more, no less.** Once the user picks 4, 8, or 12 in Step 1c, run exactly that many questions — a Step 1e follow-up replaces an existing question, it never adds to the total.
- **Minimal diffs.** Only touch the lines and sections each answered question resolves, plus any gap section it touches — do not rewrite unrelated parts of the document.
