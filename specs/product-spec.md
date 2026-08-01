> [!abstract] Metadata
> | | |
> |---|---|
> | **Status** | 🟡 Draft |
> | **Owner** | Carlos |
> | **Created** | 2026-08-01 |
> | **Updated** | 2026-08-02 |
> | **Version** | v0.1 |

## 🎯 Vision

**My AIsy Toolkit** is a distributable kit of skills and subagents for spec-driven development with AI coding agents (Claude Code, and in best-effort mode Codex CLI), installable in any repository with a one-liner or by pasting plain text — no libraries, no package managers, no friction.

## 🔥 Problem Statement

| Pain | Root Cause |
|------|-----------|
| Reproducing the same set of skills/agents in every new repo means copying `.claude/` folders by hand | There is no centralized distribution mechanism; every repo keeps its own copy, which drifts out of sync over time |
| Spec-driven development flows (product-spec, tech-spec, roadmap, plan-feature, implement-feature...) get reinvented project by project | There is no standard, versioned, reusable catalog in a single place |
| Installing AI tooling in a repo usually drags in dependencies, package managers, and configuration | Existing solutions (plugins, npm packages, marketplaces) add friction and failure surface |
| Every AI coding agent (Claude Code, Codex CLI...) expects its skills/commands in a different location and format | There is no installation layer that translates a single catalog into each agent's native format |

## 👤 Target User

- 🎯 **Primary** — Carlos, owner of the multi-repo vault: needs to replicate his set of Claude Code skills/agents in any new repo without copying folders by hand or maintaining different versions in each place.
- 👥 **Secondary** — Devs using Claude Code (and, in best-effort mode, Codex CLI) who want to adopt spec-driven development with AI agents without designing their own skills from scratch.
- 🌍 **Stretch** — Teams starting a new repository who want a standard starting point (specs, roadmap, agents) instead of improvising their own flow.

## 💎 Design Principles

- **Zero dependencies / zero friction** — installation via a one-liner fetch or by pasting plain text into any agent. No package manager, no library, and nothing to install globally beyond a single optional pointer file (the `/setup-ai` launcher) that the user has to say yes to.
- **README as product** — the README is the kit's "front": it must convince and allow installing in under 2 minutes. It is treated as the main piece, not an afterthought.
- **Extensible profiles from day one** — today only the `default` profile exists, but the installation mechanism detects and asks about available profiles without needing a redesign when new ones are added.
- **Multi-agent by adaptation, not lowest common denominator** — every supported agent (Claude Code, Codex CLI) receives the catalog translated into its native format (`.claude/commands` + `.claude/agents` vs. `.codex/skills`), not a degraded generic version.
- **Direct, jargon-free tone** — installer messages, README, and skill names are clear, short, and have a light, easygoing touch ("Keep it AIsy"), never sounding corporate.
- **Always the latest version** — no semantic versioning or release tags for *catalog distribution*: installing or re-installing always brings the current state of the catalog's main branch, with no version selection for the end user. (The repo itself does carry a SemVer `VERSION`, a `CHANGELOG.md`, and git tags `vX.Y.Z` for maintainer visibility — see ADR-006 in tech-spec.md — but that versioning is decoupled from, and does not affect, how the catalog gets installed.) The global `/setup-ai` launcher obeys the distribution rule by carrying no embedded content at all: it is a pointer that re-fetches the live instructions on every run, so it cannot go stale and needs no update mechanism of its own.

## 🏗️ Architecture

```mermaid
flowchart LR
    U[User in a target repo] -->|"one-liner from the README, or pasted instructions"| S[setup-ai]
    U -->|"/setup-ai — if the launcher was saved earlier"| L["Global launcher<br/>(one pointer file, user level)"]
    L -->|"fetches the live setup-ai on every run"| S
    S -.->|"offers to save it once, only if the user says yes"| L
    S -->|fetch| CAT[(my-aisy-toolkit<br/>profile catalog)]
    CAT -->|available profiles| S
    S -->|asks for profile if more than one| U
    S -->|asks which agent| U
    U -->|answers| AG{AI Agent}
    AG -->|Claude Code| CC[".claude/commands + .claude/agents"]
    AG -->|Codex CLI — best-effort| CX[".codex/skills"]
    CC --> D[Target repo ready for<br/>spec-driven development]
    CX --> D
```

- **User** — starts the installation from the repo where they want the kit, by one of two routes: the one-liner from the README, or the global `/setup-ai` launcher if they saved it in an earlier install. Picks a profile if asked. Does not interact directly with the `my-aisy-toolkit` repo.
- **setup-ai** — entry point (instructions/script) that fetches the catalog, always asks the user which AI agent to target (never inferred from the target repo's structure), asks for the profile only if the catalog declares more than one, and writes the corresponding files into the target repo. Both routes land here and run the exact same steps. Does not modify target-repo application code or configuration unrelated to skills/agents; the only thing it may write outside the target repo is the global launcher, and only with the user's explicit yes.
- **Global launcher (`/setup-ai`)** — optional shortcut, saved once at user level and living outside any repo. It is a pointer with no logic and no catalog content of its own: all it does is fetch the live `setup-ai` and run it against whatever repo is open, skipping the offer to save itself. `setup-ai` offers it at the end of an install, only for agents already present on the machine, only once, and never overwrites a file that already sits at its destination.
- **my-aisy-toolkit (catalog)** — single source of truth for profiles, skills, and agents, published under `/ai-toolkit/<profile>/` (e.g. `/ai-toolkit/default/`). Does not execute itself; it only serves as content for `setup-ai` to consume. This is decoupled from the repo's own internal `.claude/` folder, which is used only to develop this toolkit itself (dogfooding) and is never what gets installed into a target repo.
- **Target repo** — receives the installed files and becomes operational for spec-driven development through the corresponding AI agent's skills. Each skill/agent's internal logic lives in its own self-documented file.

## 🛠️ Interfaces

### Installation

#### One-liner (fetch of `setup-ai`)

Single command the user pastes into their terminal (or asks their agent to run) inside the target repo.

| Param | Type | Default | Description |
|-------|------|---------|--------------|
| `profile` | string | `default` | Catalog profile to install. If more than one is available and none is specified, `setup-ai` asks the user. |
| `agent` | string | asked | Target AI agent (`claude`, `codex`). Always asked explicitly; never inferred from the target repo's structure (`.claude/`, `.codex/`). |

> [!warning] Side effect
> Writes/overwrites files inside `.claude/` and/or `.codex/` in the target repo. Does not touch application code or other folders. **One opt-in exception:** at the end of the install, `setup-ai` may offer to save the global launcher — a **single** file in the agent's user-level command directory — and writes it only if the user explicitly says yes. Without that yes, nothing outside the target repo is touched, and nothing in the user's home is ever overwritten, moved, or deleted.

#### Copy-paste (plain instructions)

Plain-text block the user pastes directly into the conversation of any AI coding agent, without running any script. The agent interprets the instructions and performs the installation itself (reads the catalog, writes the files).

| Param | Type | Default | Description |
|-------|------|---------|--------------|
| `profile` | string | `default` | Same as the one-liner; the agent asks if it's not specified and several profiles exist. |

#### Global launcher (`/setup-ai`)

Optional shortcut so the user never has to go back to the README. It is **not** a copy of `setup-ai`: it is one small file whose entire body is "fetch the live `setup-ai` from GitHub and follow it against the current repo", plus an explicit instruction not to offer saving the launcher again — it is already installed.

| Agent | Where it's saved | How it's invoked |
|-------|------------------|------------------|
| Claude Code | `~/.claude/commands/setup-ai.md` | `/setup-ai` (optional `[profile]` argument) |
| Codex CLI — best-effort | `~/.codex/skills/setup-ai/SKILL.md` (fallback `~/.agents/skills/setup-ai/SKILL.md`) | `$setup-ai` — a `$` skill, not a slash command |

> The Codex row is best-effort like the rest of Codex support: the user-level path has not been verified against a real Codex CLI install, and there the command is `$setup-ai`, never `/setup-ai`.

How it gets there:

- **Only with an explicit yes.** `setup-ai` asks once, at the very end, after the repo is already set up. A no, a silence, or an ambiguous answer are all treated as no, and nothing outside the repo is written.
- **Only for agents that are actually there.** A user-level directory has to exist (`~/.claude/`, `~/.codex/` or `~/.agents/`) for that agent to even be offered. This environment check is only about the launcher — it never replaces the mandatory "which agent am I setting this up for?" question, which is always asked.
- **Only once.** If a file already sits at the destination, it is not opened, not compared, and not overwritten; the question is not asked again either, and the install reports that it left the existing file alone. Replacing it is a manual job: delete it and run the setup again.
- **Never blocking.** If the write fails (permissions, no home directory, disk), the catalog install already finished and is not reverted — the user just gets the reason in the wrap-up report.

> [!warning] Side effect
> This is the only file the kit ever writes outside the target repo, and only after the user says yes.

#### Re-installation / update

Running any of the methods above on a repo that already has the kit installed. Always brings the latest version of the catalog (no semantic versioning), adds new skills/agents from the profile, and updates existing ones that changed.

### Catalog — `default` profile

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

**Agents (Claude Code subagents)**

| Agent | Role |
|--------|-----|
| `architect` | Discovery, evaluation of alternatives, and solution design before implementing. |
| `code-developer` | Implements application code from an already-defined plan. |
| `test-developer` | Writes tests (does not run them). |
| `tester` | Runs tests and verifies the application's real behavior. |
| `ui-developer` | Designs and implements complete screens (HTML/CSS/TS/React). |
| `judge` | Reviews other agents' work and issues a PASS / CHANGES_REQUESTED verdict. |

> Codex CLI has no native equivalent to subagents; in best-effort mode only the **skills** catalog is translated to `.codex/skills/`.

## 🩺 Operations

**Healthcheck**

Verifying the installation means checking that the expected files for the installed profile exist: `.claude/commands/*.md` and `.claude/agents/*.md` for Claude Code, or `.codex/skills/*/SKILL.md` for Codex. There is no running process or endpoint to query — it's a file-presence check.

**Logging**

`setup-ai` does not generate persistent logs. It prints to stdout which skills/agents it installed, which it updated, and which were already up to date during execution.

## 📦 Deliverables

| Deliverable | Description |
|:-----------:|-------------|
| 💻 **Catalog (source code)** | `/ai-toolkit/default/commands/` (skills) and `/ai-toolkit/default/agents/` (subagents), the canonical version `setup-ai` fetches from. Populated from the maintainer's local skills vault, not authored from scratch in this repo. |
| 🛠️ **setup-ai** | Installation instructions/script: one-liner method and copy-paste method. |
| 📚 **README** | Presents the kit, installation instructions (both methods), the `default` profile catalog, and a quick usage guide. |

## 🗂️ Project Structure

> [!abstract]- File tree
> ```
> my-aisy-toolkit/
> ├── .claude/             # Internal only: this repo's own Claude Code setup, used to develop the toolkit itself (not distributed)
> │   ├── commands/
> │   └── agents/
> ├── ai-toolkit/
> │   └── default/         # Distributable catalog, profile "default"
> │       ├── commands/    # Skill catalog (11 skills)
> │       └── agents/      # Subagent catalog (6 agents)
> ├── specs/               # product-spec.md, tech-spec.md, roadmap.md for this repo itself
> ├── setup-ai.md          # Plain-text installation instructions (root)
> └── README.md            # Project front: installation, catalog, usage
> ```

## 🚫 Out of Scope

- **Exhaustive documentation of each skill/agent's internal behavior** — this ProductSpec lists the catalog, but each skill's detailed behavior lives in its own self-documented file.
- **Support for AI agents other than Claude Code and Codex CLI** (Devin, Cursor, Windsurf, etc.) — a conscious decision by the user; a possible future extension.
- **Granular version management or rollback per individual skill** — the installer always brings the latest version of the full profile; there is no selective install or reverting to previous versions.
- **Additional profiles beyond `default`** — the mechanism must support them, but their concrete content is not defined in this ProductSpec.

## 🔮 Future

- **Additional profiles** — profiles beyond `default` (e.g. `minimal`, `frontend-only`) for different project types or team preferences.
- **Verified Codex CLI support** — move from best-effort to tested support in a real Codex environment.
- **Support for other AI agents** — evaluate Devin, Cursor, Windsurf or others under the same adaptation layer.
- **Catalog version notifications** — notify when the target repo has an outdated version of the installed catalog.

## ❓ Discovery

- [x] ~~Is Codex CLI supported in v1?~~ → Yes, in best-effort mode (translated to `.codex/skills/`), documented as unverified in a real environment until it can be tested.
- [x] ~~How is the catalog versioned?~~ → Catalog *distribution* always brings the latest of the main branch; no semantic versioning or version selection there. Separately, the repo itself is now SemVer-tagged (`VERSION`, `CHANGELOG.md`, git tags `vX.Y.Z`) purely for maintainer visibility — see ADR-006 in tech-spec.md. The two are independent: bumping the repo version never changes what `setup-ai` installs.
- [x] ~~Tone for user-facing content?~~ → Direct, jargon-free, with a light easygoing touch ("Keep it AIsy").
- [x] ~~Exact location of the `setup-ai` script/instructions within the repo?~~ → Repo root (`setup-ai.md`), per tech-spec.md.
- [x] ~~Concrete mechanism for profile and active-agent selection?~~ → ADR-004: the agent is always asked explicitly (never inferred/detected from folders present); the profile is asked only if the catalog declares more than one.
