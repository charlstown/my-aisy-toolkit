---
name: implement-feature
description: Execute pending tasks from feature plan files, track completion, dependencies, retries, and blockers. Use when the user says implement-feature, develop plan, ejecuta el plan, implementa el plan, desarrolla el plan, or asks to execute specs/*/plan.md.
---

# Implement feature

Use the user's language. Find plans under `specs/*/plan.md` with unchecked tasks, inspect dependencies between selected plans, and ask which plans to run when there is more than one. Respect explicit task ownership and execute dependent work in order.

Use an isolated git worktree when supported and appropriate; otherwise state the fallback before editing. Implement each task, run relevant verification, and update the plan immediately: use `[x]` only after verification, and `[blocked]` with the reason when progress is impossible. Retry a failed task once after diagnosing it; do not hide failures.

Never alter the main working tree while isolated work is in flight. Finish with completed, blocked, and unstarted tasks, verification results, and worktree or branch locations. Do not commit, push, or open PRs without explicit user authorization.
