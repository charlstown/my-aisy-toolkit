> [!abstract] Metadata
> | | |
> |---|---|
> | **Status** | 🟢 Locked for F1.4 |
> | **Owner** | Carlos |
> | **Created** | 2026-08-01 |
> | **Updated** | 2026-08-02 |
> | **Version** | v0.1 |

---

## Pantallas

### README (`README.md`)

Página de entrada del repo (GitHub). Un desarrollador que no conoce el kit debe entender qué es, decidir instalarlo y completar la instalación sin salir del documento, en menos de 2 minutos ([[004-readme-as-product-front]] FR-001/FR-009, SC-001/SC-002).

Referencia de estilo: [FlorianBruniaux/claude-code-ultimate-guide](https://github.com/FlorianBruniaux/claude-code-ultimate-guide) — pero **simplificado**: ese README sostiene un recurso de 24k líneas con badges densos, Mermaid, `<details>` y star-history; este kit son 12 skills + 6 agents, así que se toma solo el patrón de "badges discretos de estado" y se descarta el resto (Mermaid, collapsibles, comparativas, ecosistema).

---

#### Vista (Markdown renderizado en GitHub)

```
┌────────────────────────────────────────────────┐
│ # My AIsy Toolkit                               │ ← H1
│ [version] (dinámico, shields.io, for-the-badge) │ ← badge de versión, bloque separado
│ [skills-12] [agents-6] [updated-YYYY-MM-DD]     │ ← badges shields.io, style=flat-square
│ Pitch de 1 párrafo ("Keep it AIsy")             │
├────────────────────────────────────────────────┤
│ ## 🔥 Why                                       │ ← 4 bullets, problema → solución en 1 frase
├────────────────────────────────────────────────┤
│ ## ⚡ Quick start                                │ ← sección principal, hace de instalación
│  1. bloque de código: one-liner (fetch)         │    Y de primer uso a la vez
│  2. alt. copy-paste (setup-ai.md)               │
│  3. bloque de código: /constitution              │
├────────────────────────────────────────────────┤
│ ## 📚 Catalog — default profile                 │
│  tabla Skills (12 filas, siempre visible)       │
│  tabla Agents (6 filas, siempre visible)        │
│  nota Codex CLI best-effort                     │
├────────────────────────────────────────────────┤
│ ## 🗂️ Project structure                         │ ← árbol corto (solo lo instalable)
├────────────────────────────────────────────────┤
│ ## 📝 Good to know                              │ ← reinstall/update + tabla de params
└────────────────────────────────────────────────┘
```

---

#### Quick start como sección principal (no como "Install" separado)

Decisión explícita: no hay una sección "Installation" independiente antes del Quick start. El bloque de instalación (one-liner + copy-paste, ambos con igual peso) vive **dentro** de Quick start, seguido inmediatamente del primer comando a ejecutar (`/constitution`). Razón: instalar y arrancar es un único flujo de menos de 2 minutos, separarlo en dos secciones obligaba a repetir contexto.

```
## ⚡ Quick start

#### Option A — One-liner

Paste this into your AI agent's conversation, inside the repo you want to set up:

    Fetch and follow the setup instructions at:
    https://raw.githubusercontent.com/charlstown/my-aisy-toolkit/main/setup-ai.md

#### Option B — Copy-paste

Open `setup-ai.md`, copy its full contents, and paste those into your agent instead.

Your agent installs the catalog, then prints a short summary of what got written.
Kick things off with:

    /constitution
```

Los detalles menos urgentes (reinstalar/actualizar, tabla de parámetros `profile`/`agent`) se degradan a la sección **"Good to know"**, al final del documento, para no competir con el flujo principal.

---

#### Catálogo — tablas siempre visibles (sin `<details>`)

Con solo 18 filas totales (12 skills + 6 agents) colapsar en `<details>` añade un clic sin ahorrar espacio real — a diferencia del repo de referencia, que colapsa contenido de miles de líneas. Las tablas se copian literalmente desde `specs/product-spec.md` §Catalog para evitar drift entre documentos.

```
## 📚 Catalog — default profile

**Skills**
| Skill | What it does |
|-------|----------|
| `/constitution` | ... |
... (12 filas)

**Agents** (Claude Code subagents)
| Agent | Role |
|--------|-----|
| `architect` | ... |
... (6 filas)

> [!note] Codex CLI
> Best-effort support: only the skills catalog translates to `.codex/skills/`.
```

---

#### Badges — minimal + 3 contadores

Se descartó tanto "sin badges" como "estilo `for-the-badge` grande". Se usan 3 badges estáticos de shields.io, `style=flat-square` (discretos, no corporativos):

```
![Skills](https://img.shields.io/badge/skills-12-blue?style=flat-square)
![Agents](https://img.shields.io/badge/agents-6-informational?style=flat-square)
![Updated](https://img.shields.io/badge/updated-2026--08--01-lightgrey?style=flat-square)
```

- Son estáticos (no hay backend/API que los alimente); se actualizan a mano cuando cambia el conteo del catálogo o se toca el README.
- Nada de Mermaid ni `<details>` en esta pantalla — ver Ronda 1 de decisiones más abajo.

Además de estos 3 badges estáticos `flat-square`, el README incluye un cuarto badge de **versión**, en su propio bloque justo encima (línea 14), que sí usa el estilo `for-the-badge` explícitamente descartado para los otros tres — introducido por la feature de versionado del repo (`specs/002-versionado-del-repo-version-changelog-git-tags/`). A diferencia de los 3 anteriores, este badge **no es estático**: lo alimenta en vivo el endpoint `img.shields.io/github/v/tag/charlstown/my-aisy-toolkit` a partir del último git tag, y no requiere actualización manual.

```
<img src="https://img.shields.io/github/v/tag/charlstown/my-aisy-toolkit?style=for-the-badge&label=version&color=orange" alt="Version">
```

---

#### Estado "aspiracional" (contenido vs. estado real del repo)

`setup-ai.md`, `catalog.yaml` y `ai-toolkit/default/` **no existían** en el repo cuando se diseñó esta pantalla (F1.1–F1.3 del roadmap estaban pendientes; solo había specs). El README se redactó igualmente como el resultado **final**, sin badge ni nota de "🚧 en construcción" — y esa decisión se mantuvo al cerrar 004-readme-as-product-front: F1.1–F1.3 ya están completas y mergeadas a `main`, por lo que ahora los tres elementos existen realmente en el repo y el README ya no es aspiracional sino descriptivo del estado actual. Esta pantalla (`specs/ui-spec.md`) documenta ese diseño final; no bloquea que el `README.md` real ya exista en el repo con este contenido antes de que `setup-ai.md` esté escrito — es intencional, es el "front" apuntando hacia adelante.

---

#### Project structure — árbol reducido

Solo lo que un lector necesita para entender qué se instala; se omiten `.claude/` y `specs/` del árbol (se mencionan en una nota aparte porque son internos de este repo, no parte de lo distribuible):

```
my-aisy-toolkit/
├── ai-toolkit/
│   └── default/
│       ├── commands/    # 12 skills
│       └── agents/      # 6 subagents
├── catalog.yaml
├── setup-ai.md
└── README.md
```

---

#### Adaptación tablet / desktop

No aplica — es un documento Markdown renderizado por GitHub, sin layout responsive propio más allá del que GitHub ya aplica a cualquier README.

---

## Decisiones de la entrevista (rondas)

**Ronda 1 — estructura y contenido**
- Espectáculo visual: **minimal + badges** (skills/agents/updated), sin Mermaid.
- Catálogo: **tablas completas siempre visibles**, sin `<details>`.
- Estado real del repo: **aspiracional** — se escribe el README "final" ya, aunque `setup-ai.md`/`ai-toolkit/default/` aún no existan (F1.4 se hace antes de que F1.1–F1.3 cierren).

**Ronda 2 — interacciones y detalles**
- Quick start sugiere explícitamente `/constitution` como primer comando, tras un resumen de lo instalado.
- Se incluye una versión corta de "Project structure" en el README (no solo en `product-spec.md`).
- Badges en estilo `flat-square`, discretos.

**Ajuste post-entrevista (feedback directo del usuario)**
- Quick start pasa a ser la **sección principal**, fusionando lo que iba a ser "Installation" — no hace falta explicar la instalación por separado.
- Las notas de reinstalación/actualización y la tabla de parámetros (`profile`/`agent`) bajan a una sección final, **"Good to know"**, en vez de vivir junto al bloque de instalación.
