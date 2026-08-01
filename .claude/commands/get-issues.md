---
description: Fetch open GitHub issues, let the user pick which ones to work on, and scaffold a specs/ folder with requirements.md for each selected issue.
---

## Language

Detect the language of the user's initial (or most recent) message and conduct the ENTIRE interaction in that language — every `AskUserQuestion` prompt, header, option label and description, and every message, summary, and generated file or output. Mirror the user's language exactly and never switch to another language. These instructions are written in English, but that must NOT force the interaction into English: if the user wrote in Spanish, ask and write in Spanish; if they wrote in another language, use that one. The language of the inputs determines the language of the outputs.

## Instructions

Follow these steps in order. Generate the `plan.md` files only when appropriate (Step 5) and **never** execute them.

### Step 1 — Fetch the open issues

Run the following command to fetch the repository's open issues:

```
gh issue list --state open --json number,title,body,labels --limit 50
```

If `gh` is not available or the command fails, report it to the user and stop.

### Step 2 — Show the issues and ask the user which ones to work on

**2a. Show the full list as text:**

Print in your response (plain text, without using tools) the list of up to the 10 most recent issues with this format:

```
Open issues:
#132 — Show warning for patients with empty ID or last name
#131 — Show validation message below the button...
...
```

**2b. Ask for a selection with `AskUserQuestion`:**

Use `AskUserQuestion` with `multiSelect: true`. Include the 4 most recent as options. For the rest, the user can type the number via the "Other" option (which appears automatically).

- Each option: `#<number> — <short title>`
- If there are no open issues, inform the user and finish

### Step 3 — Create the structure in `specs/` for each selected issue

For **each selected issue**, do the following:

#### 3a. Determine the folder prefix

Inspect the issue title and its labels:

| Condition | Prefix |
|-----------|--------|
| Title starts with `feat:` or `feature:`, or label `enhancement` | `feat` |
| Title starts with `bug:` or `fix:`, or label `bug` | `fix` |
| Any other case | `feat` |

#### 3b. Build the folder slug

Take the issue title, remove the conventional prefix (`feat:`, `bug:`, `fix:`, `feature:`) if it has one, and:
1. Convert everything to lowercase
2. Replace spaces and special characters with hyphens (`-`)
3. Remove double hyphens and leading/trailing hyphens
4. Limit to 50 characters

The final folder name is: `{prefix}-{slug}`

Examples:
- `feat: required description field` → `feat-required-description-field`
- `bug: amount inputs do not accept commas` → `fix-amount-inputs-do-not-accept-commas`

#### 3c. Verify the folder does not already exist

If `specs/{folder-name}/` already exists, tell the user that the issue already has a folder and skip it.

#### 3d. Create `specs/{folder-name}/requirements.md`

Create the file with this exact structure:

```markdown
# {Issue title without conventional prefix}

> GitHub: #{issue number}

## Description

{Full body of the issue exactly as it comes from GitHub, unmodified}

## Acceptance criteria

- [ ] {criterion 1}
- [ ] {criterion 2}
...
```

- The H1 is the clean title (without `feat:`, `bug:`, etc.)
- The GitHub reference links directly to the issue by its number
- The issue body is included in full, without summaries or paraphrasing
- The acceptance criteria are derived from the issue body: extract the **expected behavior**, the **relevant edge cases**, and the **success conditions** that the issue mentions explicitly or implicitly. Each criterion must be verifiable (observable in the UI or in a test). Do not invent criteria that the issue does not cover. If the issue already includes an acceptance list, use it directly.

### Step 4 — Evaluate the requirements and detect gaps

For **each** `requirements.md` created in Step 3, evaluate whether the information is sufficiently defined to plan and implement it, or whether there are **large gaps** left unresolved.

A large gap is an open decision that blocks implementation or that could lead to building the wrong solution. For example:

- Ambiguous or contradictory expected behavior.
- Lack of definition about critical edge cases.
- UX/UI, data, or flow decisions that the issue does not specify and that substantially change the solution.
- Unclarified dependencies or preconditions.

Minor implementation details that can be resolved with technical judgment during planning do not count as large gaps.

**If you detect large gaps in a `requirements.md`:**

Add a section at the end of that file with this exact format:

```markdown
## Decision gap

- [ ] {gap 1 — open question or decision, worded so the user can answer it}
- [ ] {gap 2}
...
```

Each gap must be a concrete, actionable question or decision, not a vague observation.

**When you finish the evaluation**, show the user:

- The list of folders and files created.
- The issues skipped because they already had a folder.
- For each `requirements.md`: whether it ended up **complete** (no gaps) or has a **`Decision gap`** (indicating how many gaps and which ones).

### Step 5 — Generate plan (only if there are NO gaps)

> This step is only executed for the `requirements.md` files that ended up **complete** in Step 4.
>
> **If any `requirements.md` has a `Decision gap` section, its plan is NOT generated.** The process is considered finished for that issue; the user must resolve the gaps before continuing. If **all** issues have gaps, the process ends here without generating any plan.

For each folder whose `requirements.md` ended up complete (without `Decision gap`), invoke the `plan-feature` skill passing the path of the corresponding `requirements.md`.

Invocation example: `plan-feature specs/{folder-name}/requirements.md`

Wait for `plan-feature` to finish for each folder before moving on to the next (sequential).

Do not execute the generated plans: the skill ends after generating the `plan.md` files.
