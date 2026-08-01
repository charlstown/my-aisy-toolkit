<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/logo-dark.png">
    <source media="(prefers-color-scheme: light)" srcset="assets/logo-light.png">
    <img alt="My AIsy Toolkit" src="assets/logo-light.png" width="320" height="160">
  </picture>
</p>

<p align="center">
  <strong>Go from vibe coding to Spec-Driven Development. Orchestrate agentic loops with a copy-paste catalog of skills and subagents, no install required.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-1.0-orange?style=flat-square" alt="Version">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/skills-11-blue?style=flat-square" alt="Skills">
  <img src="https://img.shields.io/badge/agents-6-informational?style=flat-square" alt="Agents">
  <img src="https://img.shields.io/badge/updated-2026--08--01-lightgrey?style=flat-square" alt="Updated">
</p>

<p align="center">
  🌐 <strong>English</strong> · <a href="README-ES.md">Español</a>
</p>

<p align="center">
  My AIsy Toolkit brings together skills and subagents ready to install in your repo, so you can start building with Spec-Driven Development and agentic loops, compatible with Claude Code and Codex CLI in best-effort mode. Point your agent at one URL (or paste one file), and any repo gets the same catalog of commands and subagents, ready to use, no libraries, no package managers, nothing to install globally.
</p>

---

## ⚡ Quick Setup

From inside the repo you want to set up, paste this into your agent's conversation:

```
Fetch and follow the setup instructions at https://raw.githubusercontent.com/charlstown/my-aisy-toolkit/main/setup-ai.md
```

Your agent fetches the file, follows the steps in it, and tells you what it installed. There's nothing to download, no package manager, and no script to run. Side effects are limited to files written inside `.claude/` and/or `.codex/` in your repo. Nothing else is touched.

---

### Terminal setup

Prefer the terminal? Pass it straight as the prompt when you start the agent:

```
claude "Fetch and follow the setup instructions at https://raw.githubusercontent.com/charlstown/my-aisy-toolkit/main/setup-ai.md"
```

```
codex "Fetch and follow the setup instructions at https://raw.githubusercontent.com/charlstown/my-aisy-toolkit/main/setup-ai.md"
```

## 📦 What will you find here?

- **11 skills** covering the full spec-driven workflow, from `/constitution` to `/clean-feature`
- **6 subagents** for architecture, implementation, testing, UI, and review
- **1 install method**: one URL or one pasted file, nothing to download
- **2 AI coding agents** supported: Claude Code (native) and Codex CLI (best-effort)

And the catalog keeps growing as new skills and agents are added.

## 📚 Catalog: default profile

**Skills**

| Skill | What it does |
|-------|----------|
| `/constitution` | Kicks off product-spec and tech-spec in sequence to bootstrap a project's root specs. |
| `/product-spec` | Generates or updates `specs/product-spec.md` by interviewing the user. |
| `/tech-spec` | Generates or updates `specs/tech-spec.md` (the technical how) from the product-spec. |
| `/roadmap` | Generates `specs/roadmap.md` from the product-spec and tech-spec. |
| `/new-issue` | Opens a bug or feature issue on GitHub, investigating or clarifying depending on type. |
| `/specify-feature` | Detects features from various sources (including open GitHub issues) and scaffolds a `requirements.md` per feature. |
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

## 🗂️ Project structure

Just the pieces that matter to a reader deciding whether to install:

```
my-aisy-toolkit/
├── ai-toolkit/
│   └── default/
│       ├── commands/    # 11 skills
│       └── agents/      # 6 subagents
├── catalog.yaml
├── setup-ai.md
└── README.md
```

## 📝 Good to know

**Re-installing or updating.** Re-running either install method on a repo that already has the kit brings the latest version of the catalog, adds any skills or agents that are new since your last install, and updates the ones that changed. There's no semantic versioning to track. You always land on the current catalog.

**Params**

| Param | Type | Default | Description |
|-------|------|---------|--------------|
| `profile` | string | `default` | Catalog profile to install. If more than one is available and none is specified, your agent asks which one you want. |
| `agent` | string | asked | Target AI agent (`claude`, `codex`). Always asked explicitly, never inferred from folders already in your repo. |

Side effects stay contained to `.claude/` and/or `.codex/` in your repo. Application code and everything else is left alone.

## 🤝 Code of Conduct

This project follows a [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you're expected to uphold it.
