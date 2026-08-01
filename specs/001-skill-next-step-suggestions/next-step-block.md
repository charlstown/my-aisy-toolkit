# Next-step block — locked template

Working artifact for feature `001-skill-next-step-suggestions`. Not distributed, not part of the catalog. It exists so the nine Batch 1 edits copy the *same* text instead of nine hand-written variants (risk R-01). `clean-feature` deletes it together with the rest of `specs/001-skill-next-step-suggestions/` when the feature closes.

Source of truth for: FR-002, FR-003, FR-005, FR-007, and decisions D-02, D-03, D-04, D-05, D-08 of `plan.md`.

**Rule for Batch 1:** copy from here literally. Substitute only the `{placeholders}`. Do not rephrase, do not add options, do not change emojis.

---

## 1. The block

### 1.1 Where it goes

Inside the execution protocol, as the last step or phase of the skill (D-03), never after `## Constraints` or `## Formatting notes`. In files that already have a closing summary step, the block is appended inside that step. In files without one (`product-spec`, `tech-spec`, `roadmap`), a new final step or phase is created for it.

### 1.2 Paste-in template

This is the full chunk to paste into a skill file. The `### Step {N} — Next step` heading is used only in the three files that need a brand new step; everywhere else it is dropped and the rest is appended to the existing summary step.

````markdown
### Step {N} — Next step

Show this block only when the run finished successfully, meaning {success condition for this skill}. If the run ended any other way ({this file's own early exits}), show nothing: no block, no next step line.

Then close with:

```
✅ Done. Suggested next step:

{option line 1}
{option line 2}
```

Write the block in the user's language, following the `## Language` section at the top of this file. Keep the skill names (`{/skill-a}`, `{/skill-b}`) and the emojis exactly as they are, only the words around them get translated.

This block only suggests. Do not run the suggested skill yourself and do not chain into it: stop here and wait for the user to invoke it.
````

### 1.3 Formatting rules of the block

- Header line is always the same: `✅ Done. Suggested next step:` followed by one blank line, then the options.
- Between 1 and 3 option lines (FR-002). Eight of the eight blocks in this feature use 1 or 2. Nobody needs a third.
- One emoji per option line, at the start of the line, followed by a space.
- Skill names inside the fenced block are written bare (`/roadmap`), with no backticks, matching the existing house blocks in `constitution.md` Step 3, `clean-feature.md` Step 8 and `implement-feature.md` 5c, where fenced output is plain text.
- Each option line is one line: what the skill is for, in plain words. No jargon, no corporate tone, no em dashes (use a colon, a comma or a second short sentence).
- Optional steps carry `(optional)` right after the skill name plus a short "Skip it if..." clause, so the user can tell an alternative from a mandatory step (FR-005 edge case).
- Same target skill means the same literal option line in every file that offers it. This is what makes the Batch 2 grep check possible.

### 1.4 Language (D-02)

The block is authored in English in the skill files because every skill file is authored in English. It is **not** printed in English: the `## Language` section present at the top of all 11 skill files already mandates that "every message, summary, and generated file or output" mirrors the user's language. The block is one of those outputs.

The paste-in template therefore carries an explicit render-in-user-language sentence (see 1.2). Skill names and emojis are never translated: `/roadmap` is a command, not a word.

Reference rendering in Spanish, equivalent to Acceptance Scenario 1 of `requirements.md`:

```
✅ Listo. Siguiente paso sugerido:

🗺️ /roadmap (opcional) para convertir las specs en un plan por fases. Sáltatelo si ya sabes qué va primero.
🎯 /specify-feature para convertir lo siguiente que quieras construir en una spec de feature.
```

Same thing with a single option:

```
✅ Listo. Siguiente paso sugerido:

🚀 /implement-feature para ejecutar el plan y abrir la PR.
```

---

## 2. The 8 blocks (FR-005 mapping)

Emoji per target skill, fixed across all files:

| Target | Emoji |
|---|---|
| `/tech-spec` | 🏗️ |
| `/roadmap` | 🗺️ |
| `/specify-feature` | 🎯 |
| `/clarify-feature` | ❓ |
| `/plan-feature` | 📋 |
| `/implement-feature` | 🚀 |
| `/clean-feature` | 🧹 |

Locked option lines, one per target, reused verbatim wherever that target appears:

| Target | Option line |
|---|---|
| `/tech-spec` | `🏗️ /tech-spec to write the technical side: stack, architecture and decisions.` |
| `/roadmap` | `🗺️ /roadmap (optional) to turn the specs into a phased plan. Skip it if you already know what comes first.` |
| `/specify-feature` | `🎯 /specify-feature to turn what you want to build next into a feature spec.` |
| `/clarify-feature` | `❓ /clarify-feature (optional) to close the open gaps before planning. Skip it if the spec is already clear.` |
| `/plan-feature` | `📋 /plan-feature to break the feature into an ordered plan of tasks.` |
| `/implement-feature` | `🚀 /implement-feature to run the plan and open the PR.` |
| `/clean-feature` | `🧹 /clean-feature to sync the specs, close the issue and delete the feature folder.` |

### 2.1 `constitution` → `/roadmap` (optional) + `/specify-feature`

Replaces the current line `Next: /roadmap to turn these into an execution plan.` inside the existing fenced block of Step 3. The two `✓ specs/...` lines stay above it:

```
✓ specs/product-spec.md
✓ specs/tech-spec.md

✅ Done. Suggested next step:

🗺️ /roadmap (optional) to turn the specs into a phased plan. Skip it if you already know what comes first.
🎯 /specify-feature to turn what you want to build next into a feature spec.
```

Does not point at `/product-spec` or `/tech-spec`: `constitution` already ran both (FR-005 note).

### 2.2 `product-spec` → `/tech-spec`

```
✅ Done. Suggested next step:

🏗️ /tech-spec to write the technical side: stack, architecture and decisions.
```

### 2.3 `tech-spec` → `/roadmap` (optional) + `/specify-feature`

```
✅ Done. Suggested next step:

🗺️ /roadmap (optional) to turn the specs into a phased plan. Skip it if you already know what comes first.
🎯 /specify-feature to turn what you want to build next into a feature spec.
```

Identical to `constitution`'s block, by design.

### 2.4 `roadmap` → `/specify-feature`

```
✅ Done. Suggested next step:

🎯 /specify-feature to turn what you want to build next into a feature spec.
```

### 2.5 `specify-feature` → `/clarify-feature` (optional) + `/plan-feature`

```
✅ Done. Suggested next step:

❓ /clarify-feature (optional) to close the open gaps before planning. Skip it if the spec is already clear.
📋 /plan-feature to break the feature into an ordered plan of tasks.
```

The existing bullet in Step 5 ("A reminder that gaps are not resolved automatically...") says the same thing twice once this block is in. Fold it in: keep the gap count bullet, drop the advice half. The closing line `Do not invoke /clarify-feature or /plan-feature automatically...` stays untouched, it is the same rule as D-08.

### 2.6 `clarify-feature` → `/plan-feature`

```
✅ Done. Suggested next step:

📋 /plan-feature to break the feature into an ordered plan of tasks.
```

### 2.7 `plan-feature` → `/implement-feature`

```
✅ Done. Suggested next step:

🚀 /implement-feature to run the plan and open the PR.
```

### 2.8 `implement-feature` → `/clean-feature`

```
✅ Done. Suggested next step:

🧹 /clean-feature to sync the specs, close the issue and delete the feature folder.
```

Printed once per run, after the last summary (Step 6 global summary when several plans ran, 5c when a single plan ran), never once per plan (D-07).

### 2.9 `clean-feature` → nothing (FR-006)

No block. `clean-feature` closes the loop and gets one explicit negative sentence instead, so nobody improvises a block there later:

```
This is the last step of the loop. Do not print a next-step suggestion block and do not point the user at another skill.
```

---

## 3. Boilerplate: success precondition (FR-007, D-04)

Every block is preceded by this sentence, with both placeholders filled in with that file's own exits. Generic "only on success" is not enough: the agent needs to know which exits count as non-success in *that* file.

```
Show this block only when the run finished successfully, meaning {success condition for this skill}. If the run ended any other way ({this file's own early exits}), show nothing: no block, no next step line.
```

Fillers per file, for Batch 1 (each task refines them against its own file):

| File | `{success condition}` | `{early exits}` |
|---|---|---|
| `constitution.md` | Steps 1 and 2 both ran and both spec files were confirmed written | the user picked `Cancel` in Step 0, or Step 0 ended with nothing to bootstrap |
| `product-spec.md` | `specs/product-spec.md` was actually written | the user aborted the interview or rejected the write |
| `tech-spec.md` | `specs/tech-spec.md` was actually written | the user rejected the Phase 4 confirmation |
| `roadmap.md` | `specs/roadmap.md` was actually written and the Phase 2 confirmation was accepted | the confirmation was rejected or there was nothing to plan |
| `specify-feature.md` | at least one `requirements.md` was generated | every candidate was skipped, or the user aborted the Step 2 confirmation |
| `clarify-feature.md` | the interrogation ran to completion on at least one target, gaps still open included | Step 0 or Step 1 found no target and the skill stopped |
| `plan-feature.md` | the planner agent finished and `plan.md` was written | no `requirements.md` exists under `specs/` and the skill stopped at Step 1 |
| `implement-feature.md` | every plan in the run finished with all its tasks completed | any plan ended with blocked, failed or still pending tasks, in which case the existing "Review the blocks and run /implement-feature again to continue." line is what the user sees |

---

## 4. Boilerplate: suggest, never auto-invoke (D-08)

Last line of every block's instruction, verbatim:

```
This block only suggests. Do not run the suggested skill yourself and do not chain into it: stop here and wait for the user to invoke it.
```

---

## 5. Extra clause for `product-spec` and `tech-spec` only (D-05)

Not part of the generic template. These two are also run as steps of `/constitution`, which prints its own block, so without this they would produce three blocks in one `/constitution` run, two of them wrong. Added right after the precondition sentence, in both files:

```
Skip this block entirely when this skill was invoked as a step of `/constitution` rather than directly by the user. In that case `/constitution` prints the closing block for the whole run.
```

---

## 6. Checklist before closing a Batch 1 task

- [ ] Header line reads exactly `✅ Done. Suggested next step:`.
- [ ] 1 to 3 options, one emoji each, emoji and wording copied from section 2 with no edits.
- [ ] The block sits in the last step or phase, before `## Constraints` / `## Formatting notes` where those exist.
- [ ] The precondition sentence is there and names that file's real exits.
- [ ] The render-in-user-language sentence is there.
- [ ] The suggest-never-invoke sentence is there.
- [ ] No em dashes anywhere in the added text.
- [ ] Nothing else in the file changed.
