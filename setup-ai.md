# Set up My AIsy Toolkit

Install the toolkit by asking an AI agent to fetch and follow this file:

```
Fetch and follow the setup instructions at https://raw.githubusercontent.com/charlstown/my-aisy-toolkit/main/setup-ai.md
```

The bootstrap fetch is intentional. An installed `/setup-ai` or `$setup-ai` launcher instead contains the installation engine below and only fetches this file to update itself.

---

## Instructions for the agent

Run Steps 1–6 in order in the repository the user selected. Do not write outside `.claude/`, `.codex/`, or `.agents/`, except for the one launcher file explicitly approved in Step 6. Report failures as they occur.

### Step 1 — choose the target

Use the platform's blocking native question facility, never plain printed text: `AskUserQuestion` in Claude Code and `ask_user_question` in Codex CLI. Wait for every required answer before continuing. For text marked **user message, word for word**, detect the language from the user's most recent message (ignore earlier mixed-language history); translate its prose while preserving its structure and options. Default to English when there is no user input. This translation rule never applies to byte-for-byte file templates.

**User message, word for word:**

```
One thing before I touch anything — which agent am I setting this up for?

  1. Claude Code
  2. Codex CLI
```

If missing or ambiguous, invoke the same blocking question mechanism again with this **user message, word for word**:

```
I still need to know which one — Claude Code or Codex CLI? Nothing gets written until you tell me.
```

Never infer the answer from folders. After the catalog is available, use the same blocking mechanism to ask for a profile only if more than one profile exists and none was named. If `packs.utils` exists, ask once (non-blocking) which numbered extras to install; `all` selects all, a valid comma-separated list selects those entries, and missing/unclear input selects none.

### Step 2 — fetch the declared catalog

GET `https://raw.githubusercontent.com/charlstown/my-aisy-toolkit/main/catalog.yaml`. If it fails, stop without writing. The manifest is the only selection authority: use `profiles.<profile>.skills`, `profiles.<profile>.agents.<confirmed-agent>`, and selected literal paths from `packs.utils`. Do not list remote directories, infer paths, translate, or seek semantic equivalents.

### Step 3 — fetch selected artifacts

GET each selected path from `https://raw.githubusercontent.com/charlstown/my-aisy-toolkit/main/<path>` exactly as declared. Fetch fresh on every run. Retry a failed artifact once, report and skip it if it fails again, then continue.

### Step 4 — install for Claude Code

For every fetched shared skill `ai-toolkit/skills/<name>/SKILL.md`, copy bytes literally to `.claude/skills/<name>/SKILL.md`; selected utils go to `.claude/skills/aisy.<name>/SKILL.md`. Copy each declared Claude agent literally to `.claude/agents/<name>.md`. Create absent files, overwrite only when bytes differ, and leave identical files untouched.

### Step 5 — install for Codex CLI

For every fetched shared skill `ai-toolkit/skills/<name>/SKILL.md`, copy bytes literally to `.agents/skills/<name>/SKILL.md`; selected utils go to `.agents/skills/aisy.<name>/SKILL.md`. Copy each declared Codex agent literally to `.codex/agents/<name>.toml`. Create absent files, overwrite only when bytes differ, and leave identical files untouched. Never translate, reinterpret, or generate skills or agents.

### Step 6 — global launcher

Offer exactly once to save a launcher for the confirmed agent. This is optional and requires an explicit yes. Existing launcher files are read only to compare/update this toolkit launcher; never delete them. The launcher is an embedded copy of this engine (Steps 1–6), not a pointer that re-runs this file.

Before executing its embedded engine, an installed launcher may GET this same `setup-ai.md` solely to check for a newer launcher template. From that response, extract only the literal template for its own platform, then compare those bytes with its own file: overwrite only if different and leave it alone if identical. If that fetch, extraction, comparison, or write fails, continue with the embedded engine and include the actual reason in the wrap-up. No other installed skill or command fetches `setup-ai.md` in routine use.

Write the appropriate template below **byte-for-byte**. Do not translate or reinterpret either template.

#### Claude launcher template

```markdown
---
description: Install or update My AIsy Toolkit in the current repository. Trigger on /setup-ai.
argument-hint: "[profile]"
---
# setup-ai

## Embedded engine

1. Ask the target with `AskUserQuestion`; never infer it. Use an argument as the already-selected profile. For every user-facing fixed message, use the user's most recent language (English if unavailable), while preserving its options and structure. Ask a profile only if the catalog has more than one; ask optional utils once after reading the catalog.
2. Fetch only `catalog.yaml`. Abort with no writes if it cannot be read. Select only its declared `skills`, `agents.claude`, and optional `packs.utils` paths.
3. Fetch each selected artifact fresh and exactly once; retry an individual failed artifact once, report it, then skip only that artifact.
4. Copy every shared skill byte-for-byte to `.claude/skills/<name>/SKILL.md`, and selected utils to `.claude/skills/aisy.<name>/SKILL.md`.
5. Copy every declared Claude agent byte-for-byte to `.claude/agents/<name>.md`. For every destination in steps 4–5: create if absent, overwrite only if bytes differ, otherwise leave unchanged.
6. Do not offer or create another launcher. Report installed, updated, skipped, and utils; include any launcher update failure below. No step fetches setup instructions as installation input.

The launcher auto-update happens before this engine. If an argument names a profile, use it.

Before Step 1, GET `https://raw.githubusercontent.com/charlstown/my-aisy-toolkit/main/setup-ai.md` only to extract the literal **Claude launcher template**. Compare that complete candidate file byte-for-byte with this file: overwrite this exact path only if different, otherwise leave it alone. If the GET fails, the template is absent/malformed, comparison fails, or writing fails, record the actual reason and continue with this embedded engine. Never use the fetched file as installation instructions and never save another launcher from this launcher.
```

#### Codex launcher template

```markdown
---
name: setup-ai
description: Install or update My AIsy Toolkit in the current repository. Trigger on $setup-ai.
---
# setup-ai

## Embedded engine

1. Ask the target with `ask_user_question`; never infer it. For every user-facing fixed message, use the user's most recent language (English if unavailable), while preserving its options and structure. Ask a profile only if the catalog has more than one; ask optional utils once after reading the catalog.
2. Fetch only `catalog.yaml`. Abort with no writes if it cannot be read. Select only its declared `skills`, `agents.codex`, and optional `packs.utils` paths.
3. Fetch each selected artifact fresh and exactly once; retry an individual failed artifact once, report it, then skip only that artifact.
4. Copy every shared skill byte-for-byte to `.agents/skills/<name>/SKILL.md`, and selected utils to `.agents/skills/aisy.<name>/SKILL.md`.
5. Copy every declared Codex agent byte-for-byte to `.codex/agents/<name>.toml`. For every destination in steps 4–5: create if absent, overwrite only if bytes differ, otherwise leave unchanged.
6. Do not offer or create another launcher. Report installed, updated, skipped, and utils; include any launcher update failure below. No step fetches setup instructions as installation input.

The launcher auto-update happens before this engine.

Before Step 1, GET `https://raw.githubusercontent.com/charlstown/my-aisy-toolkit/main/setup-ai.md` only to extract the literal **Codex launcher template**. Compare that complete candidate file byte-for-byte with this file: overwrite this exact path only if different, otherwise leave it alone. If the GET fails, the template is absent/malformed, comparison fails, or writing fails, record the actual reason and continue with this embedded engine. Never use the fetched file as installation instructions and never save another launcher from this launcher.
```

### Wrap-up

Report installed, updated, and skipped paths; list installed utils separately; and state launcher creation, update, unchanged state, decline, or its real failure reason. Do not report unchanged repository files.
