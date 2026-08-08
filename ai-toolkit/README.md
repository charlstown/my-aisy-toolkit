# Detailed catalog

## `aisy.setup-ai` and this catalog

The [main README](../README.md) explains how to run `aisy.setup-ai`. The installer asks which platform and profile you want, reads `catalog.yaml`, and copies exactly the selected artifacts. This page lets you compare each option before choosing it. Every newly installed skill uses the `aisy.<name>` identifier; existing unprefixed folders are neither migrated nor deleted.

## What to install

| If you need… | Choose… | You will get |
|---|---|---|
| The complete workflow to define, plan, build, and close features | **`default`** | 10 spec-driven development skills and 6 specialized agents. |
| The above plus interface design and UI/UX decision clarification | **`ui-ux`** | Everything in `default` + 2 UI/UX skills. |
| Extra help to research, understand, or review documents | **`utils`** | An optional pack of 3 skills, compatible with either profile. |

The tables below describe every installed item.

## Skill profiles

### `default` profile

This is the complete spec-driven development workflow, from defining the product through implementing and closing a feature.

| Skill | What it does |
|---|---|
| `aisy.constitution` | Creates the project's documentation foundation by running ProductSpec, TechSpec, and roadmap in the correct order. |
| `aisy.product-spec` | Defines or updates the vision, users, scope, and deliverables in `specs/product-spec.md`. |
| `aisy.tech-spec` | Documents the technical solution—stack, architecture, data, integrations, and operations—in `specs/tech-spec.md`. |
| `aisy.roadmap` | Turns the ProductSpec and TechSpec into phases, dependencies, and completion criteria in `specs/roadmap.md`. |
| `aisy.new-issue` | Investigates a bug or feature request and opens a well-documented GitHub issue. |
| `aisy.specify-feature` | Turns an idea, issue, URL, document, or roadmap into a numbered folder with `requirements.md`. |
| `aisy.clarify-feature` | Resolves the *gaps* already identified in `requirements.md` and consolidates the decisions. |
| `aisy.plan-feature` | Generates an actionable `plan.md` from requirements and assigns each task to the right agent. |
| `aisy.implement-feature` | Executes pending plans and manages dependencies, retries, and task status. |
| `aisy.clean-feature` | Aligns root specs with a completed feature, archives its folder, and closes the related issue. |

### `ui-ux` profile

Includes **everything in the `default` profile** and adds these two skills for designing and refining the interface.

| Additional skill | What it does |
|---|---|
| `aisy.ui-spec` | Designs a screen from the top down: content, layout, interaction, states, devices, and accessibility; writes `specs/ui-spec.md`. |
| `aisy.clarify-uix` | Resolves UI/UX decisions in `requirements.md` through structured question rounds. |

### Optional `utils` pack

This pack belongs to neither profile. It can be installed alongside `default` or `ui-ux`; its destinations use the `aisy.` prefix to avoid collisions with skills in the target repository.

| Skill | What it does |
|---|---|
| `aisy.digest` | Researches an uncertain question or decision, asks only the necessary questions, and concludes with a reasoned recommendation and alternative. |
| `aisy.grill-me` | Critically questions a document to find inconsistencies and gaps, then rewrites it using the resulting decisions. |
| `aisy.for-dummies` | Explains concepts, links, or documents in a teaching-oriented way, with examples and optional resources. |

## Native agents

Each profile installs the same six roles. Their responsibility is equivalent, but Claude uses Markdown files and Codex uses TOML files; neither variant is translated or generated from the other.

| Agent | Responsibility | Claude Code | Codex CLI |
|---|---|---|---|
| `architect` | Investigates, compares alternatives, and designs a solution with decisions and actionable steps. | `agents/claude/architect.md` | `agents/codex/architect.toml` |
| `code-developer` | Implements changes from a plan and verifies compilation or relevant checks. | `agents/claude/code-developer.md` | `agents/codex/code-developer.toml` |
| `test-developer` | Designs and writes tests without running the suite. | `agents/claude/test-developer.md` | `agents/codex/test-developer.toml` |
| `tester` | Runs tests, checks real behavior, and diagnoses failures. | `agents/claude/tester.md` | `agents/codex/tester.toml` |
| `ui-developer` | Designs and implements accessible, responsive interfaces. | `agents/claude/ui-developer.md` | `agents/codex/ui-developer.toml` |
| `judge` | Reviews completed work and returns `PASS` or `CHANGES_REQUESTED`. | `agents/claude/judge.md` | `agents/codex/judge.toml` |

## Installation destinations

| Artifact | Claude Code | Codex CLI |
|---|---|---|
| Any skill | `.claude/skills/aisy.<name>/SKILL.md` | `.agents/skills/aisy.<name>/SKILL.md` |
| Native agent | `.claude/agents/<name>.md` | `.codex/agents/<name>.toml` |

## Maintenance

- Change a skill only in `skills/<name>/SKILL.md`, then review its path in `catalog.yaml`.
- Change an agent only in its corresponding native variant.
- When profiles or utils change, check that `default`, `ui-ux`, and `utils` retain their intended coverage for both platforms.

The repository's mandatory maintenance rules are in [`../AGENTS.md`](../AGENTS.md).
