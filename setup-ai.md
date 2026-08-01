# Set up My AIsy Toolkit

These are the installation instructions for **My AIsy Toolkit** — a kit of skills and subagents for
spec-driven development. An AI coding agent reads this file and installs the kit into your repo with
its own tools. There is nothing to download, no package manager, and no script to run.

Side effects are limited to writing files inside `.claude/` and/or `.codex/` in your repo. With
your explicit yes at the end of the install, it may also write **one single file** — a global
launcher — to your agent's user-level command directory. Without that yes, nothing outside your
repo is touched.

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
- Do **not** write, move, or delete anything outside `.claude/` and `.codex/` in the user's
  repo, except — only with the user's explicit yes in Step 6 — the single file
  `~/.claude/commands/setup-ai.md` or `~/.codex/skills/setup-ai/SKILL.md` (fallback
  `~/.agents/skills/setup-ai/SKILL.md`). Outside those two exact paths the prohibition is
  absolute, and nothing in the user's home is ever deleted or moved.
- Report problems to the user in plain language, in the conversation, as they happen.

### Step 1 — Ask what you're installing

**Target agent — always ask this, word for word.** Ask it every time, even if `.claude/` or
`.codex/` already exist in the repo — never infer the target agent from folders already present
(ADR-004, FR-004):

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

  1. default — 11 skills, 6 agents
  2. <other profile> — <n> skills, <n> agents
```

If the user already named a profile in their original request, use it and skip this question.

Do not write any file until both questions are answered.

### Step 2 — Fetch and read the catalog

GET this URL to get the catalog:

```
https://raw.githubusercontent.com/charlstown/my-aisy-toolkit/main/catalog.yaml
```

It's a YAML file structured like this:

```yaml
profiles:
  <profile>:
    commands: [<source path>, <source path>, ...]
    agents: [<source path>, <source path>, ...]
```

Each entry under `commands` and `agents` is a flat string — the source path of a file in this
repo. There's nothing else to parse: no per-item objects, no destination paths. Where each file
ends up on the user's machine gets worked out later, in Step 4 or Step 5.

This is the point where you find out how many profiles the catalog declares. If there's more than
one and the user hasn't already named one, this is where you ask the profile question from Step 1
— go back and ask it now, listing every profile with its file counts. If there's only one profile,
use it and move on without asking.

Once you know the profile, `profiles.<profile>.commands` and `profiles.<profile>.agents` together
give you the full list of files to fetch in Step 3.

**If the GET returns a 404, times out, or the catalog is otherwise unreachable: stop here.** Abort
the whole installation — don't fall back to a cached or partial catalog, don't guess at file
paths. Tell the user plainly, in the conversation, that you couldn't reach the catalog and nothing
was installed. Write nothing to disk.

### Step 3 — Fetch every file in the profile

For every source path collected in Step 2 — every entry under `commands` and `agents` for the
chosen profile — issue one GET. Build the URL by concatenating the raw base with the path exactly
as it appears in the catalog:

```
https://raw.githubusercontent.com/charlstown/my-aisy-toolkit/main/<source path>
```

For example, `ai-toolkit/default/commands/constitution.md` becomes:

```
https://raw.githubusercontent.com/charlstown/my-aisy-toolkit/main/ai-toolkit/default/commands/constitution.md
```

Fetch every file fresh, every time — no caching (FR-007). Even on a re-install where you already
wrote these files locally last time, GET them again; never reuse a previous response or assume a
file hasn't changed.

**If a single file's GET returns a 404 or times out, retry that one file once.** If the retry
still fails, tell the user which file failed and why, skip only that file, and keep fetching the
rest of the profile (FR-012). This is per-file resilience — unlike Step 2's catalog fetch, one
missing skill or agent file does not abort the whole installation.

### Step 4 — Write the files (Claude Code)

This step only applies if the answer in Step 1 was Claude Code. If the target is Codex CLI, skip
straight to Step 5.

For every file fetched in Step 3, map its source path to a destination in the target repo — the
repo the user is installing into, not this one:

```
ai-toolkit/default/commands/<name>.md → .claude/commands/<name>.md
ai-toolkit/default/agents/<name>.md   → .claude/agents/<name>.md
```

Write the content exactly as fetched — byte-for-byte, no reformatting, no reflowing, no touching
front matter or whitespace. What you write must match the `ai-toolkit/default/` source in this
repo exactly (FR-008).

For each destination path:

- If the file doesn't exist yet, create it. This covers both a fresh install and a re-install that
  adds skills or agents newly added to the catalog since the last install (FR-015).
- If the file already exists and its content differs from the fetched source, overwrite it
  (FR-013).
- If the file already exists and its content is already identical to the fetched source, leave it
  alone — there's nothing to change, and nothing to report as changed.

Fetch every file fresh in Step 3 and never skip Step 3 based on what's already on disk (FR-007) —
the check for "does this already exist, and does it already match" happens here, in Step 4, file
by file, not before fetching.

As with every step, your writes here are limited to `.claude/` — never application code, never
`.codex/`, never any other folder in the target repo (FR-010).

### Step 5 — Translate and write the files (Codex CLI)

This step only applies if the answer in Step 1 was Codex CLI. If the target is Claude Code, you
already handled it in Step 4 — don't repeat this step.

Codex CLI has skills but no subagent equivalent (per the catalog's `agents` entries). Only the
`commands` files fetched in Step 3 apply here — skip any `agents` file fetched for this profile,
it has nothing to translate into.

For every `commands` file fetched in Step 3, translate it yourself, at install time, into:

```
ai-toolkit/default/commands/<name>.md → .codex/skills/<name>/SKILL.md
```

There is no pre-generated Codex-format catalog anywhere in this repo, and no external translation
service to call — you are the translator (ADR-002, FR-009). "Translate" means reading the fetched
Claude Code slash-command instructions and re-expressing them in `.codex/skills/<name>/SKILL.md`'s
format and conventions, as you understand them, preserving the original intent and behavior as
closely as you can. This is not a byte-for-byte copy like Step 4 — you're reinterpreting the
content, not relaying it unmodified.

For each destination path, apply the same rules as Step 4, scoped to `.codex/skills/`:

- If `.codex/skills/<name>/SKILL.md` doesn't exist yet, create it. This covers both a fresh install
  and a re-install that adds skills newly added to the catalog since the last install (FR-015).
- If it already exists and your translated content differs from what's already there, overwrite it
  (FR-013).
- If it already exists and is already equivalent to what you'd write now, leave it alone — nothing
  to change, nothing to report as changed.

As with every step, your writes here are limited to `.codex/` — never application code, never
`.claude/`, never any other folder in the target repo (FR-010).

**A note on quality:** this translation is best-effort. You're producing your own live
interpretation of the source content, not applying a verified mapping, so the result may vary
between runs and there's no guarantee it's a perfect equivalent of the Claude Code original. This
is a documented, known limitation of Codex support (see Edge Cases and Known Limitations) — do the
best job you can, but don't claim it's an exact translation when you tell the user what happened.

### Step 6 — Offer to save the global launcher

**If you reached this file from the already-installed global launcher, stop here and skip straight
to the Wrap up — do nothing else in this step** (FR-005). That launcher already told you not to run
this step when it pointed you here; treat that as settled and move on.

**Detect which agents are actually present in the user's environment.** Check whether `~/.claude/`
exists (Claude Code) and whether `~/.codex/` or `~/.agents/` exists (Codex CLI). An agent only
becomes a candidate for this step if its user-level directory exists — a missing directory means
that agent is not a candidate, full stop; there is no such thing here as a candidate based on an
orphaned file or a guess. **This detection applies only to the global launcher in this step. It
never replaces, weakens, or stands in for the mandatory question in Step 1** — which agent to
install the catalog for, in this repo, is always asked word for word, exactly as Step 1 describes,
no matter what you detect here (ADR-004, D-03).

**Discard any candidate whose launcher file already exists at its destination.** For Claude Code,
check whether `~/.claude/commands/setup-ai.md` exists. For Codex CLI, check **both** possible
paths — `~/.codex/skills/setup-ai/SKILL.md` and `~/.agents/skills/setup-ai/SKILL.md`. This is an
existence check only: do not open the file, do not read or compare its content, and do not
overwrite it. If a candidate's file already exists, drop it from the list and make a note — you'll
report it in the Wrap up (FR-006, FR-009, D-05).

**If no candidate is left after detection and this existing-file check, skip straight to the Wrap
up — do not ask anything** (SC-004). There's no informational or partial version of the question
below; either it gets asked in full, to at least one remaining candidate, or it isn't shown at all.

**If at least one candidate remains, ask this once, word for word**, keeping only the lines for the
agents you'd actually write for (drop the other agent's line entirely if it isn't a candidate; if
you're using the `~/.agents/` fallback for Codex — see Step 6 detection above — write that path
instead of `~/.codex/...` on its line):

```
One last thing — want a shortcut for next time?

I can save a global setup-ai command so you can install this kit in any other repo without coming
back to the README. It's one small file, it lives outside this repo, and all it does is fetch these
same instructions fresh every time — nothing gets frozen or copied.

Where it'd go:

  - Claude Code — ~/.claude/commands/setup-ai.md, then run it with /setup-ai
  - Codex CLI — ~/.codex/skills/setup-ai/SKILL.md, then run it with $setup-ai

Yes or no? Either way, this repo is already set up.
```

**If the user says no, or doesn't answer clearly, write nothing outside this repo and continue to
the Wrap up.** Unlike Step 1, an ambiguous or missing answer here does not block anything and is
not asked again — it's treated exactly the same as a no. By this point the catalog is already
installed, so there is nothing at risk in moving on.

If the user says yes: what exactly gets written, and how, for each remaining candidate follows
below.

**For Claude Code**, write to `~/.claude/commands/setup-ai.md` — creating `~/.claude/commands/`
first if it doesn't already exist. Never touch, read, or write anything else inside `~/.claude/`
while doing this; the prohibition from the top of these instructions is absolute here too.

Write this content exactly as it appears below — byte-for-byte, no reformatting, no reflowing, no
improvising a variant of your own, same criterion as Step 4 applies to the catalog files (FR-008).
Its body is deliberately built to hold nothing but instructions that point at fetching this file's
live version from GitHub — zero static content copied from the catalog (FR-004) — and it tells
whoever runs it not to run this same save-the-launcher step again, since the launcher is what got
them here (FR-005). Its own "If the fetch fails" section already covers what happens if that fetch
comes back empty: inform the user and write nothing (D-08).

```markdown
---
description: Installs or updates My AIsy Toolkit — its spec-driven skills and subagents — in the repo you are currently working in. Fetches the live setup instructions from GitHub on every run, so you always get the current catalog. Trigger when the user says "setup-ai", "install the toolkit", "instala el kit", "reinstala las skills", or invokes /setup-ai.
argument-hint: "[profile]"
---

# setup-ai

Install My AIsy Toolkit into the repo we are working in right now.

## What to do

1. Fetch this URL:

   https://raw.githubusercontent.com/charlstown/my-aisy-toolkit/main/setup-ai.md

2. Follow that file's instructions, starting at **Step 1**, against the current repo. That file is
   the source of truth: which questions to ask, which catalog to read, and where every file goes are
   all in there. This command is only a pointer — do not infer anything from it, and do not fill in
   gaps from memory.

3. **Do not run the final step that offers to save the global setup-ai launcher.** That launcher is
   this very file, and it is already installed. Finish the installation and go straight to the
   wrap-up report.

If an argument was passed ($ARGUMENTS), treat it as the catalog profile the user has already chosen
and do not ask them for it again. If it is empty, ignore it.

## If the fetch fails

If the URL 404s, times out, or is unreachable for any other reason: stop right there. Tell the user
plainly that you could not reach the setup instructions and that nothing was installed. Do not write,
overwrite, or delete a single file, do not fall back to a cached or remembered copy, and do not try
to install the kit from memory.
```

If the write itself fails — permission denied, `~/.claude/` can't be created, disk full, whatever
the reason — do not retry, do not look for an alternative path, and do not abort or revert the
catalog install you already finished for this repo. Make a note of the actual reason; you'll report
it in the Wrap up (D-07).

**For Codex CLI**, write to `~/.codex/skills/setup-ai/SKILL.md` — creating `~/.codex/skills/setup-ai/`
first if it doesn't already exist. If `~/.codex/` doesn't exist but `~/.agents/` does, write to
`~/.agents/skills/setup-ai/SKILL.md` instead, creating `~/.agents/skills/setup-ai/` first (D-04).
Never touch, read, or write anything else inside `~/.codex/` or `~/.agents/` while doing this; the
prohibition from the top of these instructions is absolute here too.

Write this content exactly as it appears below — byte-for-byte, no reformatting, no reflowing, no
improvising a variant of your own. Unlike Step 5, there is no free translation here: the launcher
never leaves the catalog, so you write the template as it is, word for word, without reinterpreting
it — same criterion Step 4 applies to the catalog files (FR-008).

```markdown
---
name: setup-ai
description: Installs or updates My AIsy Toolkit — its spec-driven skills and subagents — in the repo the user is currently working in, by fetching the live setup instructions from GitHub on every run. Use it when the user says "setup-ai", "install the toolkit", "instala el kit", "reinstala las skills", or invokes $setup-ai. Do not use it for anything other than installing this kit.
---

# setup-ai

Install My AIsy Toolkit into the repo we are working in right now.

## What to do

1. Fetch this URL:

   https://raw.githubusercontent.com/charlstown/my-aisy-toolkit/main/setup-ai.md

2. Follow that file's instructions, starting at **Step 1**, against the current repo. That file is
   the source of truth: which questions to ask, which catalog to read, and where every file goes are
   all in there. This skill is only a pointer — do not infer anything from it, and do not fill in
   gaps from memory.

3. **Do not run the final step that offers to save the global setup-ai launcher.** That launcher is
   this very skill, and it is already installed. Finish the installation and go straight to the
   wrap-up report.

If the user named a catalog profile when invoking this skill, treat it as already chosen and do not
ask them for it again.

## If the fetch fails

If the URL 404s, times out, or is unreachable for any other reason: stop right there. Tell the user
plainly that you could not reach the setup instructions and that nothing was installed. Do not write,
overwrite, or delete a single file, do not fall back to a cached or remembered copy, and do not try
to install the kit from memory.
```

In Codex CLI this command is invoked as `$setup-ai`, not a slash command. As with the rest of Codex
support, this path is best-effort (ADR-002) — including the path itself, it hasn't been verified
against a real Codex CLI installation (U-01).

If the write itself fails — permission denied, `~/.codex/` (or `~/.agents/`) can't be created, disk
full, whatever the reason — do not retry, do not look for an alternative path, and do not abort or
revert the catalog install you already finished for this repo. Make a note of the actual reason;
you'll report it in the Wrap up (D-07).

### Wrap up — Tell the user what happened

There is no log file. You are the log. At the end of every run — Claude Code or Codex CLI, fresh
install or re-install — report back in the conversation, in plain language, what happened to every
file you touched or tried to touch:

- **Installed** — files that didn't exist before and now do.
- **Updated** — files that already existed and got overwritten because the fetched (or, for Codex,
  translated) content differed from what was already there. Say that's the reason: content changed.
- **Skipped** — files you didn't write, and why. This covers a Step 3 fetch that failed twice and
  was skipped, and, for Codex, a `commands` file that couldn't be translated. Name the file and give
  the actual reason, not a generic "something went wrong."

Files that already matched what you were about to write don't need a mention — nothing changed,
nothing to report.

- **Global launcher** — everything Step 6 did or didn't do gets its own `Global launcher:` section,
  separate from Installed/Updated/Skipped above. It's the one thing that isn't a file in this repo,
  so it needs to stand out clearly as something written outside it. Unlike the repo files above,
  report the launcher whenever there's something to say about it — **including the case where it
  already existed and you left it alone.** Omit the section entirely only when there is truly
  nothing to say: you skipped Step 6 because you arrived here from the already-installed launcher,
  or no candidate agent was detected at all.

  Cover whichever of these happened, one line per agent affected:

  - **Written** — the launcher didn't exist and you saved it. Give the absolute path and how to run
    it: `/setup-ai` for Claude Code, `$setup-ai` for Codex CLI.
    ```
    - Saved ~/.claude/commands/setup-ai.md — from now on, just run /setup-ai in any repo.
    ```
    ```
    - Saved ~/.codex/skills/setup-ai/SKILL.md — from now on, just run $setup-ai in any repo.
    ```
  - **Already existed, left untouched** — you never overwrite it, so say so plainly:
    ```
    - ~/.claude/commands/setup-ai.md was already there, so I left it exactly as it was — I never overwrite it. If that file isn't this kit's launcher, delete it and run the setup again to get the new one.
    ```
  - **User declined** — a single line, not one per agent:
    ```
    - You said no, so nothing was written outside this repo. The README one-liner still works whenever you change your mind.
    ```
  - **Write failed** — give the actual reason, never a generic "something went wrong":
    ```
    - Couldn't write ~/.claude/commands/setup-ai.md — <the actual reason>. Everything in this repo installed fine; you're just missing the shortcut. Use the README one-liner next time, or fix that and run the setup again.
    ```

Something like this is enough:

```
Done. Here's what happened:

Installed:
- .claude/commands/constitution.md
- .claude/agents/spec-writer.md

Updated:
- .claude/commands/plan.md (content had changed since last install)

Skipped:
- .claude/agents/legacy-reviewer.md — fetch failed twice (404), gave up after the retry

Global launcher:
- Saved ~/.claude/commands/setup-ai.md — from now on, just run /setup-ai in any repo.
```

Keep it short and specific. The point is that the user can see exactly what's different in their
repo — and outside it — without having to go check for themselves.
