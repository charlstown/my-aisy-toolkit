> [!abstract] Metadata
> | | |
> |---|---|
> | **Status** | 🟢 Done |
> | **Owner** | Carlos |
> | **Created** | 2026-08-01 |
> | **Updated** | 2026-08-08 |
> | **Version** | v0.1 |
> | **Parent specs** | [[product-spec]] · [[tech-spec]] |
> | **Scope** | Completed evolution: target-selected `setup-ai` flow for Claude Code and Codex, declarative root catalog, shared `ai-toolkit/skills/`, native agents in `ai-toolkit/agents/claude/` and `ai-toolkit/agents/codex/`, literal copying, automatic `packs.utils`, optional target-scoped launchers, transient byte/SHA-256 verification, and conditional discovery |

## 🎯 Vision

This roadmap records the completed evolution from the initial distributable catalog into a target-selected `setup-ai` flow backed by a declarative root catalog. Skills now have one shared source in `ai-toolkit/skills/`; agents remain native in `ai-toolkit/agents/claude/` and `ai-toolkit/agents/codex/`. Installation asks explicitly for Claude, Codex, or `both`, copies the literal artifacts for the selected target plus automatic utils, and offers one target-scoped launcher authorization after local installation. Byte and transient SHA-256 verification are required after copying; runtime discovery is attempted only when supported and otherwise reported as a limitation. There are no prior PoCs blocking the start. The milestone closes when manual scratch-repo verification confirms declared source bytes land in the selected target-native destinations.

## 📊 Overview

```mermaid
flowchart LR
    subgraph Phase1["Phase 1 — Installable default profile"]
        F1[F1.1 Shared skills and native agents]
        F2[F1.2 catalog.yaml manifest]
        F3[F1.3 Global dual-agent setup-ai launcher]
        F4[F1.4 README as product front]
        F5[F1.5 Automated install verification]
    end
    GateFinal{Final Gate}
    F1 --> F2
    F2 --> F3
    F3 --> F4
    F3 --> F5
    F4 --> GateFinal
    F5 --> GateFinal
```

## 🚀 Phase 1 — Installable default profile

This phase delivers the completed product evolution: a declarative remote catalog, shared skills with native agent artifacts, and a global dual-agent `setup-ai` launcher that installs the selected profile for Claude Code and Codex after one ASCII-confirmed authorization.

| # | Feature | Depends on | Status | Notes |
|---|---|---|---|---|
| F1.1 | Populate shared `ai-toolkit/skills/` + native `ai-toolkit/agents/claude/` and `ai-toolkit/agents/codex/` | — | ✅ Done | Skills have one distributable source; each agent keeps its native artifact and catalog routes (ADR-005) |
| F1.2 | `catalog.yaml` manifest | F1.1 | ✅ Done | Declares the `default` profile: skill/agent list and source paths (ADR-003) |
| F1.3 | Target-scoped `setup-ai` launchers and embedded installer engine | F1.2 | ✅ Done | Requires an explicit target (`both` only when requested), copies only selected target artifacts plus automatic utils, then requests one launcher authorization. It never creates a missing global root; structural verification is required and discovery is conditional (ADR-004, ADR-007). |
| F1.4 | README as product front | F1.3 | ✅ Done | Presents the kit, both install methods, and the `default` profile catalog |
| F1.5 | Automated install verification check | F1.3 | ✅ Done | Installs into a dummy/scratch folder and confirms every catalog file was copied unmodified |

**Phase 1 closing criterion** — Manual scratch-repo verification confirms every source declared by the selected profile, `packs.utils`, and selected native-agent list in root `catalog.yaml` is installed byte-for-byte at its `aisy.` destination. It verifies the post-copy transient SHA-256 and frontmatter where applicable; discovery is checked only when the active session exposes it. A missing selected global root prevents only the optional launcher, never the local installation.

## 🔗 Dependency Graph

```mermaid
flowchart LR
    CATALOG[(Remote declarative catalog)] -.declares sources.-> F1[F1.1 Shared skills and native agents]
    F1 --> F2[F1.2 catalog.yaml]
    F2 --> F3[F1.3 Global dual-agent setup-ai launcher]
    F3 --> F4[F1.4 README]
    F3 --> F5[F1.5 Automated verification]
    F4 --> GATE{Final Gate}
    F5 --> GATE
```

## ✅ Gates

### Gate Final Milestone — ✅ Met

- ✅ F1.1 through F1.4 complete and merged to `main`.
- ✅ F1.5's automated check passes for a dummy-folder install via both the one-liner and copy-paste methods against Claude Code.
- ✅ The same check has been run at least once against Codex CLI (best-effort; a failure does not block the gate per ADR-002 and Known Limitations, but must be documented).
- ✅ The README alone is sufficient for someone other than Carlos to reproduce a clean install without extra context.

## 🚫 Out of Roadmap

- **Additional profiles beyond `default`** — First one delivered: the `ui-ux` profile (superset of `default`, plus `ui-spec`/`clarify-uix` skills) shipped via specs/001-add-ui-ux-profile-with-new-ui-spec-and-clarify-uix. Further profiles beyond `ui-ux` remain Future ([[product-spec]]).
- **Additional Codex runtime validation** — Future ([[product-spec]]); native Codex support is present, but broader runtime coverage remains to be verified.
- **Support for other AI agents** (Devin, Cursor, Windsurf, etc.) — Out of scope / Future ([[product-spec]]).
- **Per-skill granular versioning or rollback** — Out of scope ([[product-spec]]).
- **Catalog version notifications** — Future ([[product-spec]]).
- **Automated CI/CD or automated pre-publish testing** — Out of scope for this phase; validation stays manual per [[tech-spec]] Known Limitations.
