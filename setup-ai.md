# Set up My AIsy Toolkit

These are the installation instructions for **My AIsy Toolkit** — a kit of skills and subagents for
spec-driven development. An AI coding agent reads this file and installs the kit into your repo with
its own tools. There is nothing to download, no package manager, and no script to run.

Side effects are limited to writing files inside `.claude/` and/or `.codex/` in your repo. Nothing
else is touched.

## How to install

Pick whichever fits your agent. Both do exactly the same thing.

### Option 1 — One-liner

From inside the repo you want to set up, paste this into your agent's conversation:

```
Fetch and follow the setup instructions at https://raw.githubusercontent.com/charlstown/my-aisy-toolkit/main/setup-ai.md
```

Or pass it straight as the prompt when you start the agent from your terminal:

```
claude "Fetch and follow the setup instructions at https://raw.githubusercontent.com/charlstown/my-aisy-toolkit/main/setup-ai.md"
```

```
codex "Fetch and follow the setup instructions at https://raw.githubusercontent.com/charlstown/my-aisy-toolkit/main/setup-ai.md"
```

Your agent fetches this file, follows the steps below, and tells you what it installed.

### Option 2 — Copy-paste

Can't fetch URLs? Open this file on GitHub, copy its full contents, and paste them into your agent's
conversation instead:

<https://github.com/charlstown/my-aisy-toolkit/blob/main/setup-ai.md>

Everything below is self-contained — no other file needs to be fetched for the agent to know what to
do.

---

## Instructions for the agent

Everything above this line is for the human reading the repo. You do not need it.

- Start at **Step 1** and work through the steps in order.
- Do **not** fetch this file again, whatever route brought you here. You already have it.
- Do **not** write, move, or delete anything outside `.claude/` and `.codex/` in the user's repo.
- Report problems to the user in plain language, in the conversation, as they happen.

<!-- TODO(Batch 2): fill in the body of every step below. Titles and the question wording in Step 1
     were fixed in Batch 1 (specs/003-setup-ai-installer/plan.md) — do not reword them without
     re-opening that decision. -->

### Step 1 — Ask what you're installing

<!-- TODO(Batch 2, Step 1): FR-004, FR-005, FR-014, ADR-004. Rules to write here:
     - Always ask the target-agent question below, explicitly, before anything is written.
       Never infer the target from `.claude/`/`.codex/` folders already present in the repo.
     - If the answer is missing or unclear, ask again. Write nothing until it is answered.
     - Profile: if the user already named a profile in their request, use it and do not ask.
       Otherwise hold the profile question until the catalog is in hand (Step 2), since only the
       catalog says how many profiles exist. -->

**Target agent — always ask this, word for word:**

```
One thing before I touch anything — which agent am I setting this up for?

  1. Claude Code
  2. Codex CLI (best-effort support)
```

If the user doesn't answer, or the answer is ambiguous, ask again and write nothing:

```
I still need to know which one — Claude Code or Codex CLI? Nothing gets written until you tell me.
```

**Profile — only ask when the catalog declares more than one profile and the user hasn't named
one** (see Step 2). If the catalog declares a single profile, use it silently. Ask like this,
listing every profile the catalog declares with its file counts:

```
There's more than one profile in the catalog. Which one do you want?

  1. default — 12 skills, 6 agents
  2. <other profile> — <n> skills, <n> agents
```

### Step 2 — Fetch and read the catalog

<!-- TODO(Batch 2, Step 2): FR-006, FR-011, FR-005 (trigger point for the profile question).
     GET https://raw.githubusercontent.com/charlstown/my-aisy-toolkit/main/catalog.yaml
     Parse `profiles.<profile>.commands` and `profiles.<profile>.agents` (source paths only).
     Count the profiles; ask the Step 1 profile question here if there is more than one and the
     user hasn't named one. On 404 / unreachable: abort, tell the user, write nothing. -->

### Step 3 — Fetch every file in the profile

<!-- TODO(Batch 2, Step 3): FR-007, FR-012. One GET per file declared for the chosen profile,
     against https://raw.githubusercontent.com/charlstown/my-aisy-toolkit/main/<path from catalog>.
     No caching. On 404 / timeout: retry once, then tell the user, skip that file only, and carry
     on with the rest. -->

### Step 4 — Write the files (Claude Code)

<!-- TODO(Batch 2, Step 4): FR-008, FR-010, FR-013, FR-015. Only when the target is Claude Code.
     Write each fetched file unmodified into `.claude/commands/` or `.claude/agents/`, mirroring its
     source path. Overwrite files whose content differs; add files not yet present; touch nothing
     outside `.claude/`. -->

### Step 5 — Translate and write the files (Codex CLI)

<!-- TODO(Batch 2, Step 5): FR-009, FR-010, FR-013, FR-015, ADR-002. Only when the target is Codex
     CLI. Translate each fetched Claude Code skill into `.codex/skills/<name>/SKILL.md` yourself, at
     install time — there is no pre-generated Codex catalog and no translation service. Same
     overwrite/add rules as Step 4. Note inline that this is best-effort and may be imperfect. -->

### Wrap up — Tell the user what happened

<!-- TODO(Batch 2, closing section): mirror the Logging table in specs/tech-spec.md. Report, in
     plain language in the conversation, what was installed, what was updated (content changed), and
     what was skipped (with the reason). No log file is written. -->
