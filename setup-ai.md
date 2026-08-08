# Set up My AIsy Toolkit

Install the toolkit by asking an AI agent to fetch and follow this file:

```
Fetch and follow the setup instructions at https://raw.githubusercontent.com/charlstown/my-aisy-toolkit/main/setup-ai.md
```

For this bootstrap GET, evaluate every compatible direct-download method available in the environment once, sequentially and without ranking native fetch above another method. Record each method's structural capability result and cause, discard methods with structural failures, and select the most stable remaining method; when stability is indistinguishable, use a deterministic neutral order that does not depend on method type. Use that method and the already evaluated compatible fallbacks with this same URL. Treat `CRYPT_E_NO_REVOCATION_CHECK` as a fetch/schannel failure before HTTP, never as a 4xx/5xx response. Do not substitute a cache, memory, remote listing, or another path. Only after every compatible method fails, report that the setup instructions could not be read together with the recorded method-and-cause diagnostics; do not install or write an engine.

The bootstrap fetch is intentional. An installed `/aisy.setup-ai` or `$aisy.setup-ai` launcher retains the literal engine below and never fetches `setup-ai.md` to update itself.

---

## Instructions for the agent

Run Steps 1–6 in order in the repository the user selected. Keep the catalog, downloaded bytes, transient SHA-256 values, literal artifact plan, and per-artifact state only in memory. Do not write outside the confirmed target's local directories (`.claude/`, or `.agents/` and `.codex/`), except for a selected global launcher explicitly approved in Step 6. Report failures as they occur and continue with independent artifacts.

### Step 1 — choose the target

Use `AskUserQuestion` in Claude Code or `ask_user_question` in Codex CLI when it is available. If the native facility is unavailable, ask conversationally and wait for an answer before any dependent step. For every fixed user-facing message, use the language of the user's last linguistically detectable message (English if none exists); a numeric, boolean, blank, or otherwise language-neutral reply preserves that last detectable language. Preserve each message's options and structure. This translation rule never applies to literal file templates.

Ask exactly this question (translated only under the preceding rule):

```
One thing before I touch anything — which agent am I setting this up for?

  1. Claude Code
  2. Codex CLI
  3. Both (only if you explicitly want both)
```

If missing or ambiguous, use the same available question mechanism again:

```
I still need to know which one — Claude Code, Codex CLI, or both if you explicitly request both. Nothing gets written until you tell me.
```

Never infer the target from folders. Record the confirmed target set in memory. Accept `both` only when the user explicitly requests it; it is never a default, fallback, or consequence of detecting two folders. This is the first decision of the run.

### Step 2 — fetch the catalog, show profiles, and plan

At the beginning of this execution, evaluate every compatible direct-download method once, sequentially and never in parallel, without ranking the platform's native fetch capability above another method. Record each method's structural capability result and cause, treating `CRYPT_E_NO_REVOCATION_CHECK` as a fetch/schannel failure before HTTP rather than a 4xx/5xx response, and discard methods with structural failures. Select the most stable compatible direct method from the successful evaluations; when stability is indistinguishable, use a deterministic neutral order that does not depend on method type. Retain and reuse that selected method for the catalog and every artifact. For a resource-specific failure, record its method and cause, then try only the already evaluated compatible fallbacks sequentially with the same exact URL; do not evaluate methods again. A successful fallback becomes the preferred method for the rest of this execution. Never substitute a cache, memory, remote listing, or another path. Diagnose a resource only after the preferred method and every already evaluated compatible fallback fail.

GET `https://raw.githubusercontent.com/charlstown/my-aisy-toolkit/main/catalog.yaml` through that complete method chain. If every method fails, stop without writing. The manifest is the only selection authority; do not list remote directories, infer paths, translate, or seek semantic equivalents.

Before selecting or displaying a profile, parse the literal downloaded `/catalog.yaml` and validate it. Require a non-empty `profiles` mapping and, for every declared profile, a list at `profiles.<profile>.skills`. If Claude is confirmed, require a list at every `profiles.<profile>.agents.claude`; if Codex is confirmed, require a list at every `profiles.<profile>.agents.codex`. Validate that every declared skill or util path is a literal `ai-toolkit/skills/<name>/SKILL.md` path and that every declared target agent path is a literal `ai-toolkit/agents/claude/<name>.md` or `ai-toolkit/agents/codex/<name>.toml` path for its target. If `packs.utils` is present, require it to be a list of those literal shared-skill paths. If any required structure or declared target artifact is absent or invalid, report the concrete catalog validation failure and stop without showing profiles, building a plan, or writing. Only after validation, show every declared profile as a numbered option and list every skill path under `profiles.<profile>.skills` below its number. If there is more than one profile, ask for exactly one valid displayed number using the native question facility or the conversational fallback; wait for the answer and re-ask after any missing, non-numeric, out-of-range, or ambiguous response. If exactly one profile exists, show it as option `1` and select it. A launcher argument may supply a profile only as a valid displayed number; otherwise ask. This is the second decision of the run.

Add every literal path in `packs.utils` automatically, without a utils question. Build one literal in-memory artifact plan containing only `profiles.<profile>.skills`, every `packs.utils` path, and `profiles.<profile>.agents.claude` and/or `profiles.<profile>.agents.codex` for the confirmed target set. Every plan entry records its declared source path, exact raw URL, artifact kind, selected target destination(s), `source_sha256`, `destination_sha256` for each destination, and state. Initialize hashes as pending, set `source_sha256` from exact fetched bytes, and set each `destination_sha256` from the read-back destination bytes. Deduplicate identical source paths while preserving all selected destinations. Do not persist the plan or hashes.

### Step 3 — fetch planned artifacts

For every planned source, GET `https://raw.githubusercontent.com/charlstown/my-aisy-toolkit/main/<path>` exactly from its declared path through the selected run method and its already evaluated compatible fallbacks. Fetch each selected artifact fresh and exactly once per run. If its first complete attempt fails, retry that artifact once through the same selected method and fallback sequence. On success, retain the exact response bytes and set `source_sha256` from them before copying. On failure after both attempts, record every method and cause, mark only that artifact and its destinations failed, report it, then continue with every other planned artifact.

### Step 4 — install selected local artifacts

For a confirmed Claude target, copy every fetched shared skill and automatic util as literal bytes to `.claude/skills/aisy.<name>/SKILL.md`, deriving `<name>` only from the declared `ai-toolkit/skills/<name>/SKILL.md` path. Copy only declared Claude agents as literal bytes to `.claude/agents/<name>.md`.

For a confirmed Codex target, copy every fetched shared skill and automatic util as literal bytes to `.agents/skills/aisy.<name>/SKILL.md` and copy only declared Codex agents as literal bytes to `.codex/agents/<name>.toml`.

For every planned destination, create it if absent; otherwise compare its bytes with retained artifact bytes and overwrite only if different. Read back each created or updated destination, set its `destination_sha256`, compare its exact bytes and SHA-256 with `source_sha256`, and record `created`, `updated`, `unchanged`, or `failed` with its concrete cause. A fetch, write, or verification failure affects only that artifact or destination: continue with every other independent entry. Never translate, reinterpret, generate, alias, redirect, migrate, rename, or delete artifacts or historical unprefixed folders. Do not read, check, or write an unconfirmed target's local directories.

### Step 5 — retain the result state

Keep the per-artifact results in memory. Local failures do not prevent the optional launcher operation in Step 6, and no failed or skipped artifact may be reported as installed.

### Step 6 — optional global launcher

Resolve `~` against the effective HOME. For each confirmed target only, inspect its existing global root without creating it:

- Claude Code: `~/.claude/`, with destination `~/.claude/commands/aisy.setup-ai.md`.
- Codex CLI: `~/.codex/`, with destination `~/.codex/skills/aisy.setup-ai/SKILL.md`; only if `~/.codex/` is absent and `~/.agents/` exists, use `~/.agents/skills/aisy.setup-ai/SKILL.md`.

Never inspect, read, or write the other target's root in a single-target run. A missing selected root is a launcher failure for that target; do not create it and do not undo local installation.

Show the confirmed target's exact global destination (or missing root) and ask exactly once, using the native question facility or conversational fallback, whether to install its global `aisy.setup-ai` launcher. For an explicit `both` run, show both selected destinations and ask one authorization for both. Require an explicit yes; no, silence, or ambiguity is `rejected`. This is the third and final decision of the run.

After authorization, process each selected target independently. Copy only the exact content inside its corresponding embedded Markdown fence below, byte-for-byte, to its selected destination; do not copy the fence itself. Create only needed subdirectories beneath an existing selected root. Compare existing bytes first, overwrite only if different, then read back and verify exact bytes and transient SHA-256. Verify Claude's `description` and `argument-hint` frontmatter or Codex's `name: aisy.setup-ai` frontmatter. Attempt discovery only when the current session exposes a supported check; otherwise report the discovery limitation without treating structural verification as failed. A failure for one launcher does not block another explicitly selected launcher. Never delete or roll back a launcher.

The launcher template is retained from this bootstrap and is copied as literal content. Neither launcher may auto-update, GET `setup-ai.md`, extract a remote template, compare itself to a remote template, or write itself while invoked.

#### Claude launcher template

```markdown
---
description: Globally update or reinstall My AIsy Toolkit in the current repository. Trigger on /aisy.setup-ai.
argument-hint: "[profile-number]"
---
# aisy.setup-ai

Use this global launcher from any team repository to update or reinstall My AIsy Toolkit skills in the repository you selected.

## Embedded engine

This launcher confirms Claude Code as its only target. Do not inspect, ask for, or write Codex paths, and do not install another launcher. An optional `[profile-number]` argument is valid only when it is a displayed profile number; otherwise ask using `AskUserQuestion` when available, or a conversational fallback. Use the last linguistically detectable user language for fixed messages; numeric, boolean, blank, or neutral replies preserve that language.

1. At the beginning of this execution, evaluate every compatible direct-download method once, sequentially and never in parallel, without ranking Claude Code's native fetch capability above another method. Record structural results and causes, discard methods with structural failures, and treat `CRYPT_E_NO_REVOCATION_CHECK` as a fetch/schannel failure before HTTP, never as 4xx/5xx. Select the most stable compatible direct method from the successful evaluations; when stability is indistinguishable, use a deterministic neutral order that does not depend on method type. Retain and reuse it for the catalog and every artifact. For a resource failure, use only already evaluated compatible fallbacks sequentially with the same exact URL, promote a successful fallback for the rest of this execution, and never evaluate methods again or substitute cache, memory, remote listing, or another path. Abort without writing only after every compatible method fails.
2. GET only `https://raw.githubusercontent.com/charlstown/my-aisy-toolkit/main/catalog.yaml` with that selected method and fallbacks. Before displaying or selecting a profile, parse the literal downloaded catalog and require a non-empty `profiles` mapping, a list at every `profiles.<profile>.skills`, and a list at every `profiles.<profile>.agents.claude`. Validate every declared skill or util as a literal `ai-toolkit/skills/<name>/SKILL.md` path and every Claude agent as a literal `ai-toolkit/agents/claude/<name>.md` path; if `packs.utils` is present, require it to be a list of those literal shared-skill paths. On a missing or invalid required structure or declared Claude artifact, report the concrete catalog validation failure and stop without showing profiles, building a plan, or writing. Only then show every profile numbered with all its declared skill paths before selection; accept exactly one valid displayed number, re-asking after an invalid response (use option `1` automatically if it is the only profile). Add every `packs.utils` path automatically. Build an in-memory literal plan containing only selected profile skills, every util, and `agents.claude`, with exact URLs, destinations, states, `source_sha256`, and a `destination_sha256` for every destination; do not persist it.
3. Fetch every planned source fresh and exactly once with the selected method and already evaluated fallbacks. Retry a failed artifact once through that same sequence; after two failed attempts report methods and causes, skip only it, and continue. Retain successful bytes and set `source_sha256`.
4. Derive `aisy.<name>` from each shared skill or util path and copy bytes only to `.claude/skills/aisy.<name>/SKILL.md`; copy declared Claude agents only to `.claude/agents/<name>.md`. Create absent files, overwrite only differing bytes, read back each changed file, set `destination_sha256`, and verify it against `source_sha256`. Record each result and continue after individual fetch, write, or verification failures. Never translate, alias, redirect, migrate, rename, or delete historical unprefixed folders.
5. Report created and updated paths, an unchanged count, failures with causes, automatic utils, download method, and any discovery limitation. This launcher has no Step 6: it never fetches `setup-ai.md`, auto-updates, compares or writes a launcher, or accesses a non-Claude target.
```

#### Codex launcher template

```markdown
---
name: aisy.setup-ai
description: Globally update or reinstall My AIsy Toolkit in the current repository. Trigger on $aisy.setup-ai.
---
# aisy.setup-ai

Use this global launcher from any team repository to update or reinstall My AIsy Toolkit skills in the repository you selected.

## Embedded engine

This launcher confirms Codex CLI as its only target. Do not inspect, ask for, or write Claude paths, and do not install another launcher. Use `ask_user_question` when available, or a conversational fallback, to select exactly one valid displayed profile number when the catalog has more than one. Use the last linguistically detectable user language for fixed messages; numeric, boolean, blank, or neutral replies preserve that language.

1. At the beginning of this execution, evaluate every compatible direct-download method once, sequentially and never in parallel, without ranking Codex CLI's native fetch capability above another method. Record structural results and causes, discard methods with structural failures, and treat `CRYPT_E_NO_REVOCATION_CHECK` as a fetch/schannel failure before HTTP, never as 4xx/5xx. Select the most stable compatible direct method from the successful evaluations; when stability is indistinguishable, use a deterministic neutral order that does not depend on method type. Retain and reuse it for the catalog and every artifact. For a resource failure, use only already evaluated compatible fallbacks sequentially with the same exact URL, promote a successful fallback for the rest of this execution, and never evaluate methods again or substitute cache, memory, remote listing, or another path. Abort without writing only after every compatible method fails.
2. GET only `https://raw.githubusercontent.com/charlstown/my-aisy-toolkit/main/catalog.yaml` with that selected method and fallbacks. Before displaying or selecting a profile, parse the literal downloaded catalog and require a non-empty `profiles` mapping, a list at every `profiles.<profile>.skills`, and a list at every `profiles.<profile>.agents.codex`. Validate every declared skill or util as a literal `ai-toolkit/skills/<name>/SKILL.md` path and every Codex agent as a literal `ai-toolkit/agents/codex/<name>.toml` path; if `packs.utils` is present, require it to be a list of those literal shared-skill paths. On a missing or invalid required structure or declared Codex artifact, report the concrete catalog validation failure and stop without showing profiles, building a plan, or writing. Only then show every profile numbered with all its declared skill paths before selection; accept exactly one valid displayed number, re-asking after an invalid response (use option `1` automatically if it is the only profile). Add every `packs.utils` path automatically. Build an in-memory literal plan containing only selected profile skills, every util, and `agents.codex`, with exact URLs, destinations, states, `source_sha256`, and a `destination_sha256` for every destination; do not persist it.
3. Fetch every planned source fresh and exactly once with the selected method and already evaluated fallbacks. Retry a failed artifact once through that same sequence; after two failed attempts report methods and causes, skip only it, and continue. Retain successful bytes and set `source_sha256`.
4. Derive `aisy.<name>` from each shared skill or util path and copy bytes only to `.agents/skills/aisy.<name>/SKILL.md`; copy declared Codex agents only to `.codex/agents/<name>.toml`. Create absent files, overwrite only differing bytes, read back each changed file, set `destination_sha256`, and verify it against `source_sha256`. Record each result and continue after individual fetch, write, or verification failures. Never translate, alias, redirect, migrate, rename, or delete historical unprefixed folders.
5. Report created and updated paths, an unchanged count, failures with causes, automatic utils, download method, and any discovery limitation. This launcher has no Step 6: it never fetches `setup-ai.md`, auto-updates, compares or writes a launcher, or accesses a non-Codex target.
```

### Wrap-up

Report created and updated local paths, an aggregate unchanged count without enumerating unchanged files, every failed artifact or destination with its real cause, automatic utils, confirmed target, selected profile, used download method, and any discovery limitation. State each selected launcher outcome as `created`, `updated`, `unchanged`, `rejected` (authorization declined), or `failed` with its real reason. Mention only the launcher invocation(s) actually selected: `/aisy.setup-ai` for Claude and/or `$aisy.setup-ai` for Codex. For every exhausted GET chain, report each failed method with its cause; identify `CRYPT_E_NO_REVOCATION_CHECK` as a fetch/schannel failure before HTTP, never as a 4xx/5xx response. Do not report this diagnosis while a compatible download method remains untried.
