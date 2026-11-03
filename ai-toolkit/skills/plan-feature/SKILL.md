---
name: aisy.plan-feature
description: Given a requirements.md path, evaluates gaps, asks up to 3 critical questions if needed, discovers the repo's subagents, then invokes the planner subagent to generate a plan.md whose tasks are attributed to the best-fitting agent (`@agent`). Trigger when the user says "plan-feature", "genera el plan", "planifica esta feature", "crea el plan.md", or invokes /aisy.plan-feature.
---

## Codex question fallback

When running in Codex, use `ask_user_question` when it is available. Only when it is unavailable, ask conversationally: show each alternative in every multiple-choice or sequential question with an explicit index, and explicitly instruct the user to reply with that index or with free-form text.

Present exactly one pending question at a time, with identifiable options and an explicit instruction that the user may choose an option or provide their own answer. Wait for and process that answer before asking another question or executing a dependent step. Treat free-form answers as valid. When the user says they do not know yet (or equivalent), record a gap and continue only with independent questions or steps.

Do not change Claude Code's existing question mechanism or behavior.

## Language

Detect the language of the user's initial (or most recent) message and conduct the ENTIRE interaction in that language — every `AskUserQuestion` prompt, header, option label and description, and every message, summary, and generated file or output. Mirror the user's language exactly and never switch to another language. These instructions are written in English, but that must NOT force the interaction into English: if the user wrote in Spanish, ask and write in Spanish; if they wrote in another language, use that one. The language of the inputs determines the language of the outputs.

## Instructions

Follow these steps in order.

### Step 1 — Locate the requirements.md

The user may pass the path to the `requirements.md` as an argument to the skill, or mention it in their message.

- If a path was provided, use it directly.
- If none was provided, use `Glob` to search for all `specs/*/requirements.md` and ask the user which one they want to plan with `AskUserQuestion` (a single question, options = the paths found).
- If no `requirements.md` exists under `specs/`, inform the user and stop.

Read the selected `requirements.md` with `Read`.

### Step 2 — Evaluate critical gaps

Read the requirements carefully. Evaluate whether there are ambiguities or missing information that the planner agent **cannot resolve on its own by reading the code**. Consider it a critical gap only if it prevents writing a concrete task in the plan:

| Gap type | Examples that ARE critical | Examples that are NOT critical |
|-------------|------------------------------|------------------------------|
| Unspecified behavior for a relevant edge case | "What happens if the user saves without changes?" | "What happens if there are 0 records?" (the planner can infer it) |
| Technical decision with two equally valid options and different consequences | "Do we manage state in the parent component or in a context?" | "Do we use `useState` or `useReducer`?" (the planner chooses) |
| Ambiguous scope that could double the size of the feature | "Does the fix apply only to component A or also to component B?" | Unspecified style details (the planner reads css-spec) |

**Criterion**: if the planner can resolve it by reading the code, the css-spec, or existing patterns → **it is not a gap, do not ask**.

If you detect **0 critical gaps**, skip directly to Step 4.

If you detect **1-3 critical gaps**, continue with Step 3.

### Step 3 — Ask the user (only if there are gaps)

Use `AskUserQuestion` with **a single call** that groups all detected gaps (maximum 3 questions in the same call). The questions must be:
- Concrete and closed whenever possible (predefined options + "Other")
- Ordered from highest to lowest impact on the plan

After receiving the user's answers, keep them in mind as additional context for the planner. Do not edit the `requirements.md`.

### Step 4 — Discover the repository's agents

Before invoking the planner, check whether the repository defines its own subagents:

- Use `Glob` to search for all `.claude/agents/*.md` files.
- **If at least one exists**, read the frontmatter of each file (`name` and `description`) and build an **agent catalog** `{ @name → description }`. This catalog is passed to the planner so it attributes each task to the agent that best fits by its nature (e.g. front-end/UI → the UI agent, logic/backend → the code agent, tests → the tests agent, discovery/design → the architect).
- **If none exists**, there is no catalog: the planner will write the tasks **without** the `@agent-name` section.

Do not make up agent names: use only the real `name` values found in `.claude/agents/`.

### Step 4a — Inspect coverage and define the validation scope

Before invoking the planner, inspect the affected code, relevant existing test assertions/fixtures, test runner scripts and CI checks. Use `Existing Behavior & Coverage` from the requirements as a starting point and verify it against the current repository; older requirements without that section remain valid. Search by affected behavior even when completed specs folders no longer exist. Scope inspection to the change and its affected consumers; do not audit unrelated historical features or run the suite during planning.

Build a concise coverage decision table for the plan, grouping acceptance criteria that share the same observable behavior:

| Requirement/scenario group | Existing evidence | Decision | Missing behavior or risk |
|---|---|---|---|
| IDs or named outcomes | Test path + test/scenario name and relevant assertions, or inspection limitation | Reuse / Extend / New / Manual / Review / Pending inspection | What the existing evidence does not cover, or why no test change is needed |

Apply these rules to the table and the planner's tasks:

- **Reuse before adding.** Reuse a test when its assertions cover the required outcome, extend it when the change introduces a missing case, and create a new test only for a distinct uncovered behavior or regression risk. A similar filename is not proof of coverage. When evidence is unavailable, mark it unverified and plan focused inspection before deciding to add tests; do not default to an entirely new suite.
- **No one-to-one test quotas.** An FR, SC, acceptance scenario, or story does not automatically need its own test or task. Group equivalent cases; use existing parameterization/fixtures when appropriate. Zero new tests is valid when existing coverage or a proportionate manual check suffices, with a reason. Do not weaken explicit acceptance outcomes or required project checks to reduce counts.
- **Avoid Cartesian parameterization.** Use one representative case per rule and per affected field, varying independent dimensions separately instead of crossing every rule, field, input and mode. Add combinations only for a concrete interaction that changes behavior, and name that interaction. A compact parameterized test can still hide dozens of redundant executions; review its expanded cases.
- **Choose one sufficient level per behavior.** Prefer the level that detects the actual failure (unit, integration, or end-to-end). If a unit test covers a rule, do not repeat its assertions or case matrix in integration and E2E tests. Those levels should cover distinct wiring or user-flow risks. For example, do not recheck the same `dry_run` rule across several layers; an integration check is justified only for a separate risk such as an external write escaping the boundary. Avoid tests that mirror internal implementation, assert unchanged framework behavior, or cover unrelated edge cases.
- **Do not freeze copied content.** Do not copy constants, entire configuration files (such as `cdk.json`) or tech-spec prose into tests or snapshots just to assert equality with the source. Intentional edits would cause failures without a behavioral regression. Test the relevant semantic contract through the consumer or output, using only the minimal expected values needed to express that contract.
- **Test production behavior, not doubles.** Exercise the real code under test. Reject tests that only assert a stub returns its configured value or a mock contains data supplied by the test. Mock-call assertions are useful only when the real implementation must produce or suppress a meaningful interaction; identify the production defect the assertion would catch.
- **Assign editorial style to the judge.** Rules such as avoiding em dashes belong in the judge's review criteria, not in automated tests. Use the discovered judge agent when available, otherwise the reviewer, without inventing an agent tag. Record these outcomes as Review in the decision table so they remain accounted for without generating test-development tasks.
- **Separate writing from execution.** Test-development tasks identify the missing behavior and the existing files to extend or the reason for a new file. Execution tasks identify the smallest useful existing/new test selection, actual repository commands or manual steps, and expected outcomes. Do not add a test-development task when nothing needs to be written.
- **Bound regression work.** Start with tests for the changed behavior and affected consumers. Specify when a broader suite is required (shared contracts, cross-cutting changes, runner limitations, or mandatory CI/project policy) and why. Consolidate overlapping execution tasks across batches/features; a final run may cover the integrated changes. Repeat a passing check only after a relevant subsequent change, failure, unresolved concern, or a required gate. Never bypass mandatory checks.

Pass the table, concrete runner commands/selectors, relevant findings and these rules to the planner. Planning records intended validation, not a passed result or a fabricated test count. Use prose/table rows for this analysis, reserving task checkboxes for executable work.

### Step 5 — Invoke the planner agent

Invoke the `planner` subagent with a prompt that includes:

1. The **absolute path** of the `requirements.md`
2. The **full content** of the `requirements.md` (so the agent does not need to request it again)
3. If there were questions in Step 3: the **user's answers** as additional context, clearly marked as "User clarifications:" before the answers
4. The **agent catalog** from Step 4 (or the note that there are no agents)
5. The mandatory **task format** (see below)
6. The instruction to write the `plan.md` in **the same folder** as the `requirements.md`
7. The **coverage findings, decision table and validation rules** from Step 4a. Require a concise coverage decision table and validation scope in `plan.md`, with tasks derived from the uncovered behavior and risks rather than from the number of requirements

#### Format of each plan.md task

Each task is a `- [ ]` checkbox (essential: `implement-feature` and `agentic-loop` use `- [ ]` / `- [x]` for progress tracking).

- **With agents available** — cite the agent that will develop it right after the checkbox, separated by `·`:

  ```
  - [ ] @agent-name · Short task name: detailed description.
  ```

  `@agent-name` is the `name` from the catalog (Step 4) that best fits the task. `implement-feature` routes the task to that subagent via the `@tag`.

- **Without agents available** — the `@agent-name ·` section is omitted and the task is written directly:

  ```
  - [ ] Short task name: detailed description.
  ```

Example prompt to the planner:

```
Generate the plan.md for the feature in specs/{folder}/.

Requirements path: specs/{folder}/requirements.md

Requirements content:
---
{full content}
---

{if there were clarifications:}
User clarifications:
- Question: {question 1} → Answer: {answer 1}
- Question: {question 2} → Answer: {answer 2}

{if there are agents in the repo:}
Agents available in this repository (attribute each task to the one that best fits):
- @{agent 1}: {description of agent 1}
- @{agent 2}: {description of agent 2}
- @{…}

Format of EACH plan.md task:
- [ ] @agent-name · Short task name: detailed description.
Use only the @names from the agent list above, choosing for each task the one that best fits its nature.

{if there are NO agents in the repo:}
This repository does not define its own subagents. Write each task WITHOUT agent attribution, using this format:
- [ ] Short task name: detailed description.

Coverage findings and decision table:
{scoped findings and table from Step 4a, including inspection limitations}

Validation rules:
{rules from Step 4a}

Include the coverage decision table and validation scope in plan.md. Justify each
new/extended test by a missing behavior or risk and identify the existing tests
to reuse. Give concrete execution commands/selectors or manual steps and the
conditions for broader regression. Consolidate overlapping test work; do not
translate each requirement into a separate test or rerun the suite per task.

Write the plan.md to specs/{folder}/plan.md.
```

### Step 5a — Validate the proposed test work

Read the generated `plan.md` before reporting success. Check that the coverage decisions cite inspected evidence or explicit limitations, that every acceptance outcome is accounted for (groups may share evidence), and that each new/extended test addresses an actual gap or distinct risk. Check for duplicate cases across stories, batches or test levels, unsupported test quotas, and repeated execution with no relevant intervening change or mandatory gate. Confirm that commands/selectors match the repository's runner and mandatory checks are retained.

Explicitly reject Cartesian case expansion without an interaction risk, repeated assertions of a unit-covered rule in integration/E2E, copied constant/configuration/document equality checks, checks that only exercise doubles, and editorial-style tests. For every proposed new test, confirm that an existing test cannot cover the behavior unchanged or with a focused extension. Apply these checks to all test tasks, including proposals inherited from older requirements.

If the plan fails these checks, correct it or return concrete corrections to the planner and review the revised result. If unavailable evidence or a product decision still prevents validation, report that limitation explicitly and leave a focused discovery task or gap instead of retrying indefinitely or claiming the plan is fully validated. Do not remove required behavior to reduce the count. Do not mark tests as passed: this review validates the plan, not the implementation.

### Step 6 — Confirm to the user

When the planner agent finishes, inform the user of:
- The path of the generated `plan.md`
- The number of batches and tasks created
- If the plan attributes agents: the agents used and how many tasks it assigned to each; if there were no agents in the repo, note that
- If there were clarifications incorporated into the plan, mention them briefly
- Summarize which coverage is reused, which tests need extending/adding and why, and the execution scope (including any required broader suite or unverified coverage). Zero new tests is a valid outcome; do not invent counts that were not established.

Show this block only when the run finished successfully, meaning the planner agent finished and `plan.md` was written. If the run ended any other way (no `requirements.md` exists under `specs/` and the skill stopped at Step 1), show nothing: no block, no next step line.

Then close with:

```
✅ Done. Suggested next step:

🚀 /aisy.implement-feature to run the plan and open the PR.
```

Write the block in the user's language, following the `## Language` section at the top of this file. Keep the skill name (`/aisy.implement-feature`) and the emoji exactly as it is, only the words around it get translated.

This block only suggests. Do not run the suggested skill yourself and do not chain into it: stop here and wait for the user to invoke it.
