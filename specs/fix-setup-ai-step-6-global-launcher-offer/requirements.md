# setup-ai's Step 6 global-launcher offer can present Codex CLI even when the user chose Claude Code in Step 1

> GitHub: #30

## Description

Step 1 of `setup-ai.md` explicitly asks the user which agent it's installing for, word for word, and the user answered "Claude Code". Later, in Step 6 (the optional offer to save a global launcher), the prompt only offered **Codex CLI** as a destination — Claude Code was never mentioned, even though the user had just confirmed they use Claude Code moments earlier in the same run.

The user's own framing of the issue: if they answer "yes" to save the global launcher, the destination is obviously supposed to be for the agent they said they're using (Claude Code) — not for an agent they never selected.

## Steps to reproduce

1. Run the `setup-ai` one-liner inside a repo from Claude Code.
2. At Step 1, answer "Claude Code" when asked which agent to install for.
3. Let the install finish (skills/agents get written to `.claude/`).
4. At Step 6, when asked "One last thing — want a shortcut for next time?", observe the "Where it'd go:" list.

## Expected behavior

Since the user explicitly confirmed "Claude Code" in Step 1, Step 6's offer should include Claude Code as a candidate destination (`~/.claude/commands/setup-ai.md`, run with `/setup-ai`) — at minimum for the agent already confirmed in Step 1, regardless of what Step 6's own independent environment probe finds.

## Actual behavior

The "Where it'd go:" list only showed:
```
- Codex CLI — ~/.codex/skills/setup-ai/SKILL.md, then run it with $setup-ai
```
Claude Code was completely absent from the offer. The user had to type a free-text correction ("Es en claude no en CODEX") instead of being able to pick Claude Code from the options shown.

## Evidence

### Screenshot
User-provided screenshot of the conversation, showing (top) the Step 1 question already answered "Claude Code", and (bottom) the Step 6 prompt offering only the Codex CLI destination line, with the user's manual correction typed into the free-text field.

### Console / Network
Not applicable — this is a conversational skill-instructions flow (`setup-ai.md`), not a browser-based application; no console or network evidence applies.

## Files involved

- `setup-ai.md`, Step 6 — "Offer to save the global launcher" (lines 227-279 as of this writing)
- `setup-ai.md`, Step 1 — "Ask what you're installing" (lines 61-70), for context on the answer that Step 6 does not reuse

## Cause hypothesis

Step 6's instructions run their **own, independent candidate detection**: "Detect which agents are actually present in the user's environment. Check whether `~/.claude/` exists (Claude Code) and whether `~/.codex/` or `~/.agents/` exists (Codex CLI). An agent only becomes a candidate for this step if its user-level directory exists." This detection is explicitly documented as decoupled from Step 1 ("This detection applies only to the global launcher in this step. It never replaces... the mandatory question in Step 1").

That decoupling is the likely root cause: in the user's environment, Step 6's directory-existence check apparently did not find `~/.claude/` as a candidate (or found its launcher file already present there and silently dropped it — the instructions say to "make a note" for the Wrap-up, but that note is not part of the Step 6 prompt itself, so nothing in the moment explains the omission to the user) while `~/.codex/` or `~/.agents/` was detected as a candidate. The result is a Step 6 offer that can silently exclude the exact agent the user just confirmed in Step 1 and instead surface only an agent they never selected — a confusing, seemingly arbitrary outcome from the user's point of view.

## Environment

- Branch: `main`
- OS: iOS (Claude mobile app / dispatched Claude Code session), reported by a Windows 11 user of the toolkit repo
- Reproduction context: `/setup-ai` one-liner run against a target repo ("facturito-app") from Claude Code
- Reproduced: Yes (user-provided screenshot)

## Acceptance criteria

- [ ] When the user has confirmed "Claude Code" as the target agent in Step 1, Step 6's global-launcher offer (when shown at all) always includes Claude Code as a candidate destination, regardless of what Step 6's own directory-existence probe finds for other agents.
- [ ] Step 6 never presents an offer that names only an agent different from the one the user confirmed in Step 1, without also naming the confirmed agent, unless the confirmed agent's launcher file already exists at its destination (the existing, already-defined "discard if file already exists" exclusion).
- [ ] If the confirmed agent's candidacy is dropped from Step 6's offer for a legitimate reason (its launcher file already exists, or its user-level directory genuinely doesn't exist), the user is told why in the moment — not left to infer it or discover it only in the Wrap-up note.
