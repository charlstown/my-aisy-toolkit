> [!abstract] Metadata
> | | |
> |---|---|
> | **Status** | 🟢 Done |
> | **Owner** | Carlos |
> | **Created** | 2026-08-01 |
> | **Updated** | 2026-08-07 |
> | **Version** | v0.1 |
> | **Parent specs** | [[product-spec]] · [[tech-spec]] |
> | **Scope** | Completed evolution: local self-updating launcher, declarative remote catalog, shared `ai-toolkit/skills/`, native agents in `ai-toolkit/agents/claude/` and `ai-toolkit/agents/codex/`, literal copying, and sequential Codex prompts |

## 🎯 Vision

This roadmap records the completed evolution from the initial distributable catalog into a local self-updating launcher backed by a declarative remote catalog. Skills now have one shared source in `ai-toolkit/skills/`; agents remain native in `ai-toolkit/agents/claude/` and `ai-toolkit/agents/codex/`. Installation fetches the catalog and artifacts, copies them literally, and asks Codex questions sequentially. There are no prior PoCs blocking the start. The milestone closes when an automated check confirms a dummy-repo install lands every declared source byte-for-byte.

## 📊 Overview

```mermaid
flowchart LR
    subgraph Phase1["Phase 1 — Installable default profile"]
        F1[F1.1 Shared skills and native agents]
        F2[F1.2 catalog.yaml manifest]
        F3[F1.3 Self-updating launcher]
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

This phase delivers the completed product evolution: a declarative remote catalog, shared skills with native agent artifacts, and a local self-updating launcher that installs the selected profile and agent unassisted.

| # | Feature | Depends on | Status | Notes |
|---|---|---|---|---|
| F1.1 | Populate shared `ai-toolkit/skills/` + native `ai-toolkit/agents/claude/` and `ai-toolkit/agents/codex/` | — | ✅ Done | Skills have one distributable source; each agent keeps its native artifact and catalog routes (ADR-005) |
| F1.2 | `catalog.yaml` manifest | F1.1 | ✅ Done | Declares the `default` profile: skill/agent list and source paths (ADR-003) |
| F1.3 | Local self-updating launcher and embedded installer engine | F1.2 | ✅ Done | Explicit auto-update; fetches the remote catalog and artifacts, bootstraps the selected profile/agent, copies sources literally, and asks Codex decisions one at a time (ADR-004) |
| F1.4 | README as product front | F1.3 | ✅ Done | Presents the kit, both install methods, and the `default` profile catalog |
| F1.5 | Automated install verification check | F1.3 | ✅ Done | Installs into a dummy/scratch folder and confirms every catalog file was copied unmodified |

**Phase 1 closing criterion** — F1.5's automated check runs against a dummy folder and confirms every source declared by the selected profile and agent in `catalog.yaml` was installed as a byte-for-byte copy. The same check is attempted against Codex CLI at least once and its result documented; additional runtime validation remains future work.

## 🔗 Dependency Graph

```mermaid
flowchart LR
    CATALOG[(Remote declarative catalog)] -.declares sources.-> F1[F1.1 Shared skills and native agents]
    F1 --> F2[F1.2 catalog.yaml]
    F2 --> F3[F1.3 Self-updating launcher]
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
