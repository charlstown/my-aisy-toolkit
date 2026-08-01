<!-- DRAFT SCRATCH FILE — not the final README. Batch 3 assembles this into README.md, then deletes this file. -->
<!-- Section order and sourcing locked in specs/004-readme-as-product-front/plan.md Batch 1 handoff. -->

<!-- SECTION 1+2 (hero task): H1 + badges + pitch + ## Why -->
# My AIsy Toolkit

![Skills](https://img.shields.io/badge/skills-12-blue?style=flat-square)
![Agents](https://img.shields.io/badge/agents-6-informational?style=flat-square)
![Updated](https://img.shields.io/badge/updated-2026--08--01-lightgrey?style=flat-square)

**My AIsy Toolkit** is a distributable kit of skills and subagents for spec-driven development with AI coding agents — Claude Code, and Codex CLI in best-effort mode. Point your agent at one URL (or paste one file), and any repo gets the same catalog of commands and subagents, ready to use — no libraries, no package managers, nothing to install globally.

## 🔥 Why

- Copying `.claude/` folders by hand into every new repo gets old fast, and those copies drift apart — there's no central place they all pull from.
- Spec-driven flows like product-spec, tech-spec, roadmap, and plan-feature get reinvented from scratch in project after project, instead of living in one reusable catalog.
- Most AI-tooling installs drag in dependencies, package managers, and config just to get started — this one is a one-liner or a paste, nothing else.
- Claude Code and Codex CLI each expect skills in their own location and format, so this kit translates one catalog into whichever format your agent needs.

<!-- SECTION 3 (installation task): ## Quick start, ### 1 Install / ### 2 Answer two questions -->
## ⚡ Quick start

### 1. Install

Pick whichever fits your agent. Both do exactly the same thing.

#### Option 1 — One-liner

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

Your agent fetches the file, follows the steps in it, and tells you what it installed.

#### Option 2 — Copy-paste

Can't fetch URLs? Open [`setup-ai.md`](https://github.com/charlstown/my-aisy-toolkit/blob/main/setup-ai.md) on GitHub (it's at the root of this repo), copy its full contents, and paste them into your agent's conversation instead. That one file is self-contained — nothing else needs to be fetched for your agent to know what to do.

There's nothing to download, no package manager, and no script to run either way. Side effects are limited to files written inside `.claude/` and/or `.codex/` in your repo — nothing else is touched.

### 2. Answer two questions

Before writing anything, your agent asks:

- **Which agent are you setting this up for?** — Claude Code or Codex CLI (best-effort support). Asked every time, word for word, even if `.claude/` or `.codex/` already exist in your repo — it's never inferred from what's already there.
- **Which profile do you want?** — only asked if the catalog has more than one profile and you haven't already named one. Defaults to `default` (12 skills, 6 agents) whenever there's just a single profile, or once you've named the one you want.

Nothing gets written to disk until both are answered.

<!-- SECTION 4 (catalog task): ## Catalog — default profile -->
## 📚 Catalog — default profile

**Skills**

| Skill | What it does |
|-------|----------|
| `/constitution` | Kicks off product-spec and tech-spec in sequence to bootstrap a project's root specs. |
| `/product-spec` | Generates or updates `specs/product-spec.md` by interviewing the user. |
| `/tech-spec` | Generates or updates `specs/tech-spec.md` (the technical how) from the product-spec. |
| `/roadmap` | Generates `specs/roadmap.md` from the product-spec and tech-spec. |
| `/get-issues` | Fetches open GitHub issues and scaffolds a `requirements.md` per selected issue. |
| `/new-issue` | Opens a bug or feature issue on GitHub, investigating or clarifying depending on type. |
| `/specify-feature` | Detects features from various sources and scaffolds a `requirements.md` per feature. |
| `/clarify-feature` | Closes the pending decision gaps in one or more `requirements.md` files. |
| `/grill-me` | Critical interrogation of a document to reduce gaps and inconsistencies. |
| `/plan-feature` | Generates `plan.md` from a `requirements.md`, attributing tasks to subagents. |
| `/implement-feature` | Orchestrates the execution of one or more `plan.md` files using git worktrees. |
| `/clean-feature` | Aligns the root specs with completed work and closes the associated issue. |

**Agents** (Claude Code subagents)

| Agent | Role |
|--------|-----|
| `architect` | Discovery, evaluation of alternatives, and solution design before implementing. |
| `code-developer` | Implements application code from an already-defined plan. |
| `test-developer` | Writes tests (does not run them). |
| `tester` | Runs tests and verifies the application's real behavior. |
| `ui-developer` | Designs and implements complete screens (HTML/CSS/TS/React). |
| `judge` | Reviews other agents' work and issues a PASS / CHANGES_REQUESTED verdict. |

> [!note] Codex CLI
> Codex CLI has no native equivalent to subagents; in best-effort mode only the **skills** catalog is translated to `.codex/skills/`.

<!-- SECTION 3 cont. (quick-start task): ### 3 Run your first command, inside Quick start -->
### 3. Run your first command

Once your agent reports it's done, kick things off with:

```
/constitution
```

- It bootstraps `specs/product-spec.md` and `specs/tech-spec.md` for the repo you just installed into — the standard starting point for spec-driven work.
- Prefer to go step by step instead? Run `/product-spec` on its own first.
- Not sure what else is there? The **Catalog** section below lists all 12 skills and 6 subagents — that's your menu of entry points from here.

<!-- SECTION 5+6 (Batch 3 assembly task): ## Project structure, ## Good to know -->
<!-- TODO(Batch 3) -->
