---
description: Interviews the user top-down (content structure → layout → interaction/states → devices/accessibility) to design a UI screen, presents an initial concept and ASCII mockups before each question round, runs a self-critique pass, and writes/updates specs/ui-spec.md. Trigger when the user says "design the screen", "define the UI for...", "ui spec", or invokes /aisy.ui-spec.
---

## Codex question fallback

When running in Codex, use `ask_user_question` when it is available. Otherwise ask conversationally.

Present exactly one pending question at a time, with identifiable options and an explicit instruction that the user may choose an option or provide their own answer. Wait for and process that answer before asking another question or executing a dependent step. Treat free-form answers as valid. When the user says they do not know yet (or equivalent), record a gap and continue only with independent questions or steps.

Do not change Claude Code's existing question mechanism or behavior.

## Language

Detect the language of the user's initial (or most recent) message and conduct the ENTIRE interaction in that language — every `AskUserQuestion` prompt, header, option label and description, and every message, summary, and generated file or output. Mirror the user's language exactly and never switch to another language. These instructions are written in English, but that must NOT force the interaction into English: if the user wrote in Spanish, ask and write in Spanish; if they wrote in another language, use that one. The language of the inputs determines the language of the outputs.

## Design principle: top-down, no premature detail

This skill always moves **from high level to low level — never the reverse**:

1. **Content structure first** (information architecture) — what sections/blocks this screen needs, what each one is for, and in what order. No layout yet.
2. **Layout second** — how those blocks are arranged on screen (the ASCII mockup).
3. **Interaction and detail last** — taps/swipes, secondary states, microcopy, devices, accessibility.

**Never descend to a lower level while a higher-level gap is still open.** If, while gathering interaction or detail-level answers, a structural ambiguity surfaces (e.g. "should this actually be its own section?", "do these two blocks belong together?"), stop and resolve it at the content-structure level first — do not paper over an unresolved structural question with a low-level answer.

## Workflow

### 1. Read existing context

Read in parallel (skip any that don't exist):

- `specs/ui-spec.md` — design system already defined (tokens, components, previous screens)
- `specs/product-spec.md` — vision, users, design principles, navigation flows
- `specs/tech-spec.md` — stack, technical constraints, UI libraries
- `README.md` — general project description

Note down:
- The **visual language** already established (colors, typography, radii, shadows)
- The **screens already documented**, to avoid duplicating or contradicting them
- The product's **design principles** (e.g. mobile-first, max N taps, batch entry)

> **Structure vs. aesthetics:** this skill's ASCII wireframes encode **layout and structure only**. Color, typography, exact spacing, and other aesthetic decisions belong to the project's own design system, if one exists — never invent them here.

### 2. Identify the screen to design

If the user passed an argument (e.g. `/aisy.ui-spec home`, `/aisy.ui-spec onboarding`), use that name. If not, ask in **a single line of text** before continuing:

> "Which screen do you want to design? (e.g. home, onboarding step 1, entry sheet, settings…)"

### 3. Present an initial concept in the terminal — BEFORE asking questions

Work top-down, in two explicit passes — never jump straight to layout:

**3a. Content structure (high level).** In plain text, list the sections/blocks this screen needs, what each one is for, and their order — the information architecture — based on the context read. No layout, no ASCII yet.

**3b. Initial layout mockup (low level, built on 3a).** Only once 3a exists, show an **initial ASCII mockup** of how those blocks arrange on screen. Include:

- Reference dimensions (e.g. `390 px — mobile`)
- Layout structure with blocks and `←` annotations
- The most likely elements given the screen type (list, form, modal, etc.)

Keep this initial mockup deliberately **low-fidelity and structural**, more architecture than pixel-perfect. Over-specifying it constrains whoever implements it afterward — leave room for reasonable implementation decisions instead of fixing every detail upfront.

Then briefly list the **UX improvements you're proposing** beyond the bare minimum requested. This gives the user perspective before answering the questions.

### 4. Round 1 — Structure and content

Use `AskUserQuestion` with **exactly 3 questions** focused on:

| Header | Focus |
|--------|-------|
| **Grouping** | How is the content organized? (grouping, order, visual hierarchy) |
| **Content per element** | What information does each item, row, card, or section show? |
| **Primary element** | What is the dominant element or action on the screen? (FAB, CTA, list, form…) |

Adapt the options to the identified screen type. Use `preview` on options whenever possible — ASCII mockups in previews help the user choose visually.

**Do not write any files yet.**

**Gate before moving on:** Round 1 is the high-level, content-structure round. Before starting Round 2, confirm every structural question above is actually resolved — grouping, per-element content, and the primary element. If any answer leaves a structural ambiguity open, ask one more targeted follow-up now. Do not carry an unresolved high-level gap into Round 2 hoping a lower-level answer will paper over it.

### 5. Round 2 — Interactions, states and microcopy

Use `AskUserQuestion` with **2–3 questions** focused on:

| Header | Focus |
|--------|-------|
| **Interaction** | How does the user interact with the elements? (tap, swipe, long-press, hover) |
| **States & microcopy** | What secondary states exist (empty, loading, error, filtered, edit mode), and what does each one actually *say* (empty-state copy, error messages, confirmation text)? |
| **Contextual data** | Are there summaries, totals, indicators, or conditional banners? |

Show the **updated concept** in the terminal — the revised content structure **and an updated ASCII mockup** reflecting Round 1's answers — before launching these questions.

**Do not write any files yet.**

### 6. Round 3 — Devices, edge cases and accessibility

Before launching these questions, show the ASCII mockup updated with Round 2's interaction/state decisions.

Use `AskUserQuestion` with **up to 3 questions** focused on:

| Header | Focus |
|--------|-------|
| **Multi-device** | How does the screen adapt to tablet/desktop? (columns, widths, icons vs. swipe) |
| **Empty / error state** | What does the user see when there's no data or something fails? |
| **Accessibility** | Keyboard focus order and visible focus states, color contrast, `aria-*` labeling needs, and `prefers-reduced-motion` behavior for any animation |

If the answers from previous rounds already cover these points, skip this round (and its mockup update).

### 7. Self-critique pass (before writing anything)

Before writing to `specs/ui-spec.md`, check the drafted concept against:

- Does this look like a generic template screen, or does it actually resolve this product's specific brief and the constraints gathered in Rounds 1–3?
- Is there any part of the design that defaults to a common pattern that doesn't actually fit the real use case?
- Is the drafted document **coherent across its sections** — does the mobile view, each behavior section, the empty state, and the tablet/desktop adaptation all agree with each other and with what was decided in the interview?
- Does **every key question raised in Rounds 1–3 have an answer** reflected somewhere in the draft, with nothing silently left open?

If gaps surface here, adjust the concept using what was already gathered — do not silently invent new decisions. Only go back to the user with a new question if something is genuinely unresolved and can't be inferred from the interview so far.

### 8. Generate the final section and write to `specs/ui-spec.md`

With all the answers collected, write the screen's section following this structure:

```markdown
### {Screen name} (`{route}`)

{1–2 sentence description: what the user does here and when they arrive.}

---

#### Mobile view ({reference px})

\```
{Full ASCII diagram with ← annotations on the right}
\```

---

#### {Behavior section 1} (e.g. "Dynamic totals bar", "Row interaction")

{Description + ASCII diagram of the relevant states}

---

#### {Behavior section 2} (e.g. "Filter by category", "Search")

{Description + ASCII diagram if applicable}

---

#### Empty state

\```
{ASCII diagram of the empty state}
\```

- {Icon style spec}
- {Copy spec — the exact text shown}

---

#### Tablet / desktop adaptation

\```
{ASCII diagram of the wide version}
\```

---

#### Flow between states (optional)

If the screen has meaningful transitions between states or to other screens (not layout — flow), a small Mermaid diagram can complement the ASCII mockups above. Mermaid is reserved strictly for this: state/screen transition flow, never as a substitute for the ASCII layout diagrams.
```

**Diagram writing rules:**

- Use `┌─┐ │ └─┘` for containers, `├─┤` for internal separators
- Annotations always on the right with `←`
- Show concrete framework/CSS classes or values in annotations when the project's stack is known from `specs/tech-spec.md` (e.g. `← bg-white h-16`)
- Truncate long text with `...` to simulate real behavior
- Include the position of any fixed/floating element if one exists (e.g. `position: fixed, bottom-6, right-6`)
- Show swipe/hover states in separate blocks within the same section
- Every state described (empty, loading, error, confirmation) must include the **actual copy** shown to the user — never a placeholder like "{error message}"

**If `specs/ui-spec.md` doesn't exist**, create it with minimal scaffolding:

```markdown
> [!abstract] Metadata
> | | |
> |---|---|
> | **Status** | 🟡 Draft |
> | **Owner** | — |
> | **Created** | {YYYY-MM-DD} |
> | **Updated** | {YYYY-MM-DD} |
> | **Version** | v0.1 |

---

## Screens

{new section here}
```

**If it already exists**, add the new section inside `## Screens`, or update the existing section if the screen was already documented. The current conversation's information is **master** — in case of conflict with the file's previous content, overwrite with what was decided in the interview.

Update the `**Updated**` date and bump the version (`v0.x → v0.x+1`) when writing.

---

## Screen types and their specific questions

Adapt each round's questions based on the detected type:

### List / Log

- **Round 1:** grouping (by date, category, status), per-row content (2 lines, chips, badges), dominant element (FAB, inline filter)
- **Round 2:** row interaction (swipe, tap, long-press), summaries/totals (fixed or dynamic), conditional banner, **empty-state and error copy**
- **Round 3:** tablet columns, empty state (first-time vs. no-results), **keyboard/focus order for row actions**

### Form / Onboarding

- **Round 1:** steps (wizard vs. single page), required vs. optional fields, logical order
- **Round 2:** validation (inline vs. on submit), special fields (upload, date picker, selector), visible progress, **error message copy per field**
- **Round 3:** step navigation (back), skipping optional steps, **focus management between steps, `aria-live` for validation errors**

### Modal / Bottom Sheet

- **Round 1:** trigger (FAB, tap on an element, contextual action), available content and actions, whether it closes between actions or persists
- **Round 2:** confirmation for destructive actions, internal scroll, loading state after an action, **confirmation/cancel copy**
- **Round 3:** desktop size (centered modal vs. side drawer), **focus trap and Escape-to-close behavior**

### Dashboard / Summary

- **Round 1:** key metrics or KPIs, visual priority order, cards vs. list vs. table
- **Round 2:** data interactivity (drill-down, period filter), data refresh, **empty/loading-state copy for metrics**
- **Round 3:** desktop grid layout (N columns), **screen-reader announcement for live-updating numbers**

---

## Constraints

- Write in the same language the user uses
- Use **ASCII art** for all layout diagrams — never Mermaid for layout; Mermaid is optional and reserved strictly for screen/state transition flow, never as a substitute for the ASCII layout diagrams
- `AskUserQuestion` options should include `preview` whenever an ASCII mockup helps compare options visually
- The user can always answer with free text ("Other") — never force predefined options
- Do not invent colors, fonts, or components outside the design system already defined in `ui-spec.md`; if no prior system exists, note explicitly that none was found rather than inventing one
- Keep wireframes deliberately low-fidelity and structural — do not over-specify pixel-level detail that should be left to implementation; more detail in the wireframe tends to produce worse output from whoever implements it afterward
- Do not write any file before completing at least Round 1 and Round 2
- Show an updated ASCII mockup before every round that runs, reflecting what was learned in the prior round
- Run the self-critique pass (Step 7) before writing the final section, to catch designs that are generic rather than specific to the actual brief, and to confirm the draft is internally coherent with no key question left unanswered
- Every state described (empty, loading, error, confirmation) must include the actual copy shown to the user, not a placeholder
- Every screen must consider basic accessibility (keyboard focus order, contrast, `aria-*` labeling, reduced motion) before being marked complete
- Keep diagrams within 80 characters of width so they're readable in any editor
- One screen per invocation — if the user asks for several, prioritize the first and suggest invoking `/aisy.ui-spec` again for the rest
