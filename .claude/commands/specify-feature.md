---
description: Detects features from a file, a URL, a repo's roadmap.md, GitHub issues, or a vague prompt, lets the user pick which ones to develop, and scaffolds a numbered specs/ folder with a spec-kit-style requirements.md per feature — evidencing gaps instead of resolving them. Trigger when the user says "specify-feature", "especifica", "define los requirements", or invokes /specify-feature.
---

## Language

Detect the language of the user's initial (or most recent) message and conduct the ENTIRE interaction in that language — every `AskUserQuestion` prompt, header, option label and description, and every message, summary, and generated file or output. Mirror the user's language exactly and never switch to another language. These instructions are written in English, but that must NOT force the interaction into English: if the user wrote in Spanish, ask and write in Spanish; if they wrote in another language, use that one. The language of the inputs determines the language of the outputs.

## Purpose

Turn one or several already-existing feature descriptions (a file, a URL, a roadmap, GitHub issues, or a raw prompt) into `requirements.md` specs. Unlike `grill-me`, this skill never interrogates the user to resolve ambiguity: it writes down what it has and evidences everything unclear in a `DEFINITION GAP` section for the user to resolve later.

## Instructions

Follow these steps in order.

### Step 1 — Detect the input source

Determine where the feature(s) come from, in this priority order:

**1a. Explicit input** — the user passed an argument to `/specify-feature` or referenced one in their message: a file path, a URL, or free text.

Classify it:

| Input looks like | Treat as |
|---|---|
| Path to an existing file (verify with `Glob`/`Read`) | **File.** If it structurally holds several features (a roadmap-style document with multiple phase/feature tables, or a list that clearly enumerates distinct features) → **multi-feature**. Otherwise → **single feature**. |
| URL matching `github.com/{owner}/{repo}/issues/{n}` | **Single GitHub issue.** Fetch with `gh issue view {n} --json number,title,body,labels` (fallback: `WebFetch` the URL if `gh` fails). |
| URL matching `github.com/{owner}/{repo}` (no issue number) | **GitHub issues source** — go to the GitHub flow in 1c, scoped to that repo. |
| Any other URL | Fetch with `WebFetch`. Apply the same single-vs-multi-feature detection as for files. |
| Free text, not a path or URL | **Vague prompt.** One feature = the whole text, unless it plainly enumerates several distinct items (bullets, numbered list, clearly separate feature names) → treat each as its own candidate. |

**1b. No explicit input — look for `specs/roadmap.md`** (`Glob`). If it exists, read it and extract every feature listed under its `## 🚀 Phase N` tables (`| # | Feature | Depends on | Notes |` rows, per the `roadmap` skill's RMAP template).

Exclude features that are already marked as done: a checked box (`[x]`), a `✅`/`Done`/`Completed` marker, strikethrough, or a linked tracking issue that is closed. If completion status is ambiguous for a row, include it and note the ambiguity in its future `DEFINITION GAP`.

**1c. No explicit input and no `specs/roadmap.md` — check for GitHub issues.** If the repo has a GitHub remote and `gh` is available (`gh repo view` succeeds), fetch open issues:

```
gh issue list --state open --json number,title,body,labels --limit 50
```

**1d. Nothing above resolved it** — ask the user with `AskUserQuestion`:

- Question: "Where are the features you want to specify?"
- Options: `A file in the repo` (ask the path as follow-up via "Other" if needed), `GitHub issues`, `I'll paste the description/URL now`

If the user still gives nothing usable, inform them and stop.

### Step 2 — Build the candidate list and confirm the selection

Normalize every detected feature into `{ title, raw_description, source }`.

- **If Step 1 already resolved to exactly one unambiguous feature** (a single file, a single issue URL, a single-feature prompt) — treat it as selected automatically, no question needed. Tell the user which feature was detected and that you're proceeding with it.
- **Otherwise** (roadmap with several pending features, open issues list, a multi-feature file/URL, or a prompt enumerating several items):
  1. Print the full candidate list as plain text (title + short source tag, e.g. `roadmap · F1.2`, `#132`, `file`).
  2. Use `AskUserQuestion` with `multiSelect: true`. Include the first 4 candidates as options plus an `All` option (`description`: "Develop all detected features"). The rest are reachable via the automatic "Other" option by number/name.
  3. If the user's original message already expressed a preference (e.g., named a subset), pre-filter the options to that subset before asking, but still confirm.
  4. If the user selects nothing meaningful, default to **All**.

### Step 3 — Assign branch numbers and slugs

For the selected features, compute names **before** creating anything, so parallel writes never collide:

1. `Glob` for existing `specs/*` folders and find the highest `###-` numeric prefix already used (3-digit, zero-padded). Start at `001` if none exist.
2. For each selected feature, in the order presented: build a kebab-case slug from its title (lowercase, spaces/special chars → `-`, collapse double hyphens, trim, max 50 chars), then assign the next sequential number.
3. Folder name: `specs/{NNN}-{slug}/`. Branch name (used inside the template): `{NNN}-{slug}`.
4. If `specs/{NNN}-{slug}/` already exists for a feature that logically matches (e.g., re-running specify on the same roadmap row), skip it and tell the user it already has a folder.

### Step 4 — Generate `requirements.md` for each selected feature (in parallel)

Features are independent of each other — dispatch **one subagent per feature in parallel** (single message, multiple `Agent` tool calls) rather than looping sequentially. Each subagent receives:

- The absolute path to write: `specs/{NNN}-{slug}/requirements.md`
- The feature's `raw_description` (issue body, roadmap row + surrounding phase context, file excerpt, or the user's original prompt) — this is what `$ARGUMENTS` in the template stands for
- The exact template below and the instruction to fill it **using only the information available**, without inventing decisions or trying to resolve ambiguity

Template (fill every bracketed placeholder; keep section order and headings exactly as shown):

```markdown
# [FEATURE NAME]
Feature Branch: [NNN-feature-name]

Created: [DATE]

Status: Draft

Input: User description: "$ARGUMENTS"

## User Scenarios & Testing (mandatory)

### User Story 1 - [Brief Title] (Priority: P1)

[Describe this user journey in plain language]

Why this priority: [Explain the value and why it has this priority level]

Independent Test: [Describe how this can be tested independently - e.g., "Can be fully tested by [specific action] and delivers [specific value]"]

Acceptance Scenarios:

1. Given [initial state], When [action], Then [expected outcome]
2. Given [initial state], When [action], Then [expected outcome]

### User Story 2 - [Brief Title] (Priority: P2)

[same structure as User Story 1]

### User Story 3 - [Brief Title] (Priority: P3)

[same structure as User Story 1]

[Add more user stories as needed, each with an assigned priority. Only include as many as the source material actually supports.]

## Edge Cases

- What happens when [boundary condition]?
- How does system handle [error scenario]?

## Requirements (mandatory)

### Functional Requirements

- FR-001: System MUST [specific capability]
- FR-002: System MUST [specific capability]
- FR-003: Users MUST be able to [key interaction]

Mark anything not resolvable from the source with the inline marker, e.g.:

- FR-00N: System MUST authenticate users via [NEEDS CLARIFICATION: auth method not specified - email/password, SSO, OAuth?]

### Key Entities (include if feature involves data)

- [Entity 1]: [What it represents, key attributes without implementation]
- [Entity 2]: [What it represents, relationships to other entities]

## Success Criteria (mandatory)

### Measurable Outcomes

- SC-001: [Measurable metric]
- SC-002: [Measurable metric]
- SC-003: [User satisfaction metric]
- SC-004: [Business metric]

## Assumptions

- [Assumption about target users]
- [Assumption about scope boundaries]
- [Assumption about data/environment]
- [Dependency on existing system/service]

## DEFINITION GAP

- [ ] {open question or missing decision the source material does not resolve — worded so the user can answer it directly}
- [ ] {dependency on another feature, system, or team not yet confirmed}
```

Rules for filling it:

- **Never invent** what the source doesn't say. If a section has nothing to draw from (e.g., no data entities mentioned), state so briefly rather than fabricating content, or omit that subsection if the template marks it optional (`Key Entities`).
- **Do not try to resolve ambiguity.** Every open question, missing decision, or unconfirmed dependency goes into `## DEFINITION GAP` instead of being guessed at. This is the key difference from `grill-me` (which interrogates the user) and from `get-issues`' `Decision gap` (which blocks planning) — `specify` just documents the gap and moves on.
- `DEFINITION GAP` always has at least one bullet. If nothing is genuinely unclear, write a single bullet: `- [x] No blocking gaps detected — source material is self-contained.`
- Split `DEFINITION GAP` bullets naturally into clarification questions and dependency callouts; do not label them as separate subsections, just keep each bullet self-explanatory.
- `Created` uses today's date (`YYYY-MM-DD`).
- `Priority` P1/P2/P3 is inferred from how the source material orders or emphasizes journeys; if the source only describes one journey, write a single User Story and drop the rest.

### Step 5 — Summary

After all subagents finish, show the user:

- The folders created (`specs/{NNN}-{slug}/requirements.md`), one per feature.
- Any candidates skipped because they already had a folder.
- For each generated `requirements.md`: the number of `DEFINITION GAP` bullets (or "no gaps detected").
- A reminder that gaps are not resolved automatically — the user should run `/clarify-feature` on that feature (or edit the file directly) before running `/plan-feature` on it.

Do not invoke `/clarify-feature` or `/plan-feature` automatically: `specify-feature` always stops after generating the `requirements.md` files.
