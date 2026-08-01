#!/usr/bin/env python
"""PreToolUse(Bash) hook: deny any `git push` that targets the `main` branch.

Reads the hook input JSON on stdin (schema: {"tool_input": {"command": "..."}}),
scans each `;`/`&&`/`||`/`|`-separated segment for a `git push` invocation, and
blocks it if the push explicitly names `main` (as a whole word: `origin main`,
`HEAD:main`, `origin :main`, etc.) or is a bare push (only flags / origin /
upstream / HEAD as arguments) issued while the current branch is `main`.

This is a heuristic safety net, not a full git command parser — see CLAUDE.md
for the actual policy (every change to `main` goes through a PR).
"""
import json
import re
import subprocess
import sys

ALLOW = {"continue": True}
SEGMENT_SPLIT_RE = re.compile(r"&&|\|\||;|\|")
PUSH_RE = re.compile(r"\bgit\b.*\bpush\b")
MAIN_WORD_RE = re.compile(r"(?<![\w-])main(?![\w-])")
BARE_TOKEN_RE = re.compile(r"^-|^(origin|upstream|HEAD)$")


def current_branch():
    try:
        return subprocess.check_output(
            ["git", "rev-parse", "--abbrev-ref", "HEAD"],
            stderr=subprocess.DEVNULL,
            text=True,
        ).strip()
    except Exception:
        return ""


def targets_main(segment):
    if MAIN_WORD_RE.search(segment):
        return True

    parts = re.split(r"\bpush\b", segment, maxsplit=1)
    after = parts[1] if len(parts) > 1 else ""
    tokens = after.split()
    remainder = [t for t in tokens if not BARE_TOKEN_RE.match(t)]
    if not remainder:
        return current_branch() == "main"
    return False


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        print(json.dumps(ALLOW))
        return

    cmd = (data.get("tool_input") or {}).get("command") or ""
    if not cmd:
        print(json.dumps(ALLOW))
        return

    push_segments = [s for s in SEGMENT_SPLIT_RE.split(cmd) if PUSH_RE.search(s)]
    if not push_segments:
        print(json.dumps(ALLOW))
        return

    if any(targets_main(seg) for seg in push_segments):
        print(json.dumps({
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": (
                    "Direct pushes to main are blocked in this repo (see CLAUDE.md). "
                    "Push a branch and open a PR instead."
                ),
            }
        }))
        return

    print(json.dumps(ALLOW))


if __name__ == "__main__":
    main()
