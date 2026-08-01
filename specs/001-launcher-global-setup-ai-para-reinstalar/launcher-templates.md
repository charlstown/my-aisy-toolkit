# Launcher templates y textos del Step 6 — texto literal y definitivo

Source: `specs/001-launcher-global-setup-ai-para-reinstalar/plan.md` (Batch 0)
Issue: #8

> **Artefacto efímero.** Este fichero es material de trabajo de esta feature: no se distribuye, no
> se instala en ningún repo, no entra en `catalog.yaml` y desaparece con la carpeta `specs/001-…/`
> cuando se cierre el issue. Su único propósito es fijar el texto **antes** de tocar `setup-ai.md`,
> para que los Batches 1 y 2 copien y el Batch 5 verifique contra una referencia estable.
>
> Lo que va entre bloques ` ``` ` marcados como **VERBATIM** es texto literal: se copia
> carácter a carácter, sin reformatear, sin reflowing, sin "mejorar" la redacción.

## Contexto verificado

Comprobado leyendo los ficheros el 2026-08-01 (no son suposiciones):

- **Estilo de pregunta de la casa** — `setup-ai.md` L61-72: bloque de código, primera línea con
  guion largo que desarma al usuario (`One thing before I touch anything — …`), opciones indentadas
  con dos espacios, cero jerga, cero "please". El Step 6 imita ese patrón.
- **Estilo del Wrap up** — `setup-ai.md` L221-254: categorías en negrita (`Installed` / `Updated` /
  `Skipped`), una línea por fichero, la razón real entre paréntesis, y la regla "lo que no cambió no
  se menciona". El ejemplo de L239-251 es un bloque de código plano.
- **Frontmatter válido de Claude Code** — verificado en `~/.claude/commands/grill-me.md` (solo
  `description`) y en `~/.claude/commands/setup-ai.md` legacy (`description` + `argument-hint` +
  `allowed-tools`). En `ai-toolkit/default/commands/` conviven dos variantes: solo `description`
  (mayoría) y `name` + `description` (+ `when_to_use` en `roadmap.md` y `tech-spec.md`). Todas las
  `description` de la casa terminan con la lista de triggers (`Trigger when the user says …`).
- **Frontmatter de skill de Codex** — la doc oficial (developers.openai.com/codex/skills, vía
  learn.chatgpt.com/docs/build-skills) exige exactamente dos campos: `name` y `description`, y define
  la `description` como el mecanismo de trigger ("explain exactly when this skill should and should
  not trigger"). Invocación explícita: `$skill-name` en Codex CLI (confirma U-02). Ubicación de
  usuario documentada: `$HOME/.agents/skills/` (confirma el fallback de D-04).
- **Design Principles** — `specs/product-spec.md` L29-36: "Direct, jargon-free tone … light,
  easygoing touch ('Keep it AIsy'), never sounding corporate" y "Always the latest version".
- **`setup-ai.md` no tiene Step 6 todavía**: hoy termina en el Step 5 (L219) y el Wrap up empieza en
  L221. Nada de lo de aquí está aún en producción.

## Decisiones tomadas en este Batch 0

**B0-1 — El frontmatter de Claude lleva `description` + `argument-hint: "[profile]"`, y no lleva
`allowed-tools` ni `model`.**
Descartado: (a) solo `description`; (b) incluir `allowed-tools`.
Por qué: (b) queda excluido por el propio enunciado del plan y con razón — el launcher necesita
fetch de red y escritura en `.claude/`/`.codex/`, y cualquier `allowed-tools` que se escriba hoy se
quedará corto en cuanto cambien los nombres de las tools; una lista incompleta rompe el launcher de
forma silenciosa. Sobre `argument-hint`: el perfil es **el único parámetro** que el flujo acepta
(`product-spec.md` §Interfaces, tabla de L67-70) y el Step 1 ya contempla que el usuario lo haya
nombrado de antemano ("If the user already named a profile in their original request, use it and
skip this question", L85). Cuesta una línea de frontmatter y una del cuerpo. Además desambigua
frente al `argument-hint: "[optional-target-repo-path]"` del launcher **legacy** que hay en esta
misma ruta (R-01): sin él, un agente con ese hábito podría leer el argumento como una ruta de repo.

**B0-2 — El `name` del frontmatter: no en Claude, sí en Codex.**
Por qué: en Claude Code el nombre del comando lo da el nombre del fichero (`setup-ai.md` →
`/setup-ai`), y la mayoría del catálogo propio omite `name`. En Codex `name` es obligatorio por la
doc oficial y el fichero siempre se llama `SKILL.md`, así que sin `name` la skill no tiene identidad.

**B0-3 — Ninguna de las dos plantillas pre-responde la pregunta del Step 1.**
Descartado: que la plantilla de Codex diga "el agente destino es Codex CLI, no preguntes".
Por qué: ADR-004 es tajante — el agente destino se pregunta **siempre**, nunca se infiere. Que el
usuario invoque el launcher desde Codex no implica que quiera el kit en formato Codex en ese repo
(puede estar preparando un repo para alguien que usa Claude Code). Lo único que las plantillas
suprimen es el Step 6 (FR-005). Esto es exactamente lo que audita el check (f) del Batch 6.

**B0-4 — La pregunta del Step 6 es de sí/no, no un menú numerado.**
Descartado: replicar el formato `1. / 2.` del Step 1 ofreciendo elegir agente.
Por qué: los agentes candidatos ya los ha decidido la detección del Step 6 (D-03) y la aclaración del
usuario dice "solo para el agente presente". Un menú convertiría una decisión ya tomada en una
elección nueva, justo en el paso cuyo objetivo es reducir fricción. La lista indentada se mantiene,
pero como **información** de dónde iría el fichero, no como opciones a elegir.

**B0-5 — El Wrap up del launcher va en su propia sección, y el caso "ya existía" se reporta siempre.**
Por qué: D-05 y R-01. Es lo único que se escribe fuera del repo del usuario: mezclarlo con
`Installed` lo esconde. Y si el fichero ya existía, callarse deja al usuario creyendo que tiene el
launcher nuevo cuando puede tener el legacy.

---

## 1. Plantilla Claude Code → `~/.claude/commands/setup-ai.md`

**VERBATIM** — se escribe tal cual, incluidas las tres rayas del frontmatter:

```markdown
---
description: Installs or updates My AIsy Toolkit — its spec-driven skills and subagents — in the repo you are currently working in. Fetches the live setup instructions from GitHub on every run, so you always get the current catalog. Trigger when the user says "setup-ai", "install the toolkit", "instala el kit", "reinstala las skills", or invokes /setup-ai.
argument-hint: "[profile]"
---

# setup-ai

Install My AIsy Toolkit into the repo we are working in right now.

## What to do

1. Fetch this URL:

   https://raw.githubusercontent.com/charlstown/my-aisy-toolkit/main/setup-ai.md

2. Follow that file's instructions, starting at **Step 1**, against the current repo. That file is
   the source of truth: which questions to ask, which catalog to read, and where every file goes are
   all in there. This command is only a pointer — do not infer anything from it, and do not fill in
   gaps from memory.

3. **Do not run the final step that offers to save the global setup-ai launcher.** That launcher is
   this very file, and it is already installed. Finish the installation and go straight to the
   wrap-up report.

If an argument was passed ($ARGUMENTS), treat it as the catalog profile the user has already chosen
and do not ask them for it again. If it is empty, ignore it.

## If the fetch fails

If the URL 404s, times out, or is unreachable for any other reason: stop right there. Tell the user
plainly that you could not reach the setup instructions and that nothing was installed. Do not write,
overwrite, or delete a single file, do not fall back to a cached or remembered copy, and do not try
to install the kit from memory.
```

## 2. Plantilla Codex CLI → `~/.codex/skills/setup-ai/SKILL.md` (fallback `~/.agents/skills/setup-ai/SKILL.md`)

**VERBATIM** — mismo contenido que la de Claude, adaptado a las convenciones de skill de Codex
(`name` + `description` obligatorios, invocación con `$setup-ai`, sin sustitución de `$ARGUMENTS`):

```markdown
---
name: setup-ai
description: Installs or updates My AIsy Toolkit — its spec-driven skills and subagents — in the repo the user is currently working in, by fetching the live setup instructions from GitHub on every run. Use it when the user says "setup-ai", "install the toolkit", "instala el kit", "reinstala las skills", or invokes $setup-ai. Do not use it for anything other than installing this kit.
---

# setup-ai

Install My AIsy Toolkit into the repo we are working in right now.

## What to do

1. Fetch this URL:

   https://raw.githubusercontent.com/charlstown/my-aisy-toolkit/main/setup-ai.md

2. Follow that file's instructions, starting at **Step 1**, against the current repo. That file is
   the source of truth: which questions to ask, which catalog to read, and where every file goes are
   all in there. This skill is only a pointer — do not infer anything from it, and do not fill in
   gaps from memory.

3. **Do not run the final step that offers to save the global setup-ai launcher.** That launcher is
   this very skill, and it is already installed. Finish the installation and go straight to the
   wrap-up report.

If the user named a catalog profile when invoking this skill, treat it as already chosen and do not
ask them for it again.

## If the fetch fails

If the URL 404s, times out, or is unreachable for any other reason: stop right there. Tell the user
plainly that you could not reach the setup instructions and that nothing was installed. Do not write,
overwrite, or delete a single file, do not fall back to a cached or remembered copy, and do not try
to install the kit from memory.
```

### Diferencias entre las dos plantillas (deliberadas, no deriva)

| | Claude | Codex |
|---|---|---|
| Frontmatter | `description` + `argument-hint` | `name` + `description` |
| Trigger en la `description` | `invokes /setup-ai` | `invokes $setup-ai` (U-02) + frase de cuándo **no** usarla (la doc de Codex lo pide) |
| Cómo se llama a sí mismo | "This command" | "This skill" |
| Perfil como argumento | `$ARGUMENTS` (Claude lo sustituye) | "if the user named a profile" (Codex no sustituye) |
| Autorreferencia en el punto 3 | "this very file" | "this very skill" |

El cuerpo (URL, "start at Step 1", punto 3 de supresión y bloque de fallo de fetch) es **idéntico
palabra por palabra** salvo esas casillas. Cualquier otra divergencia que aparezca en el Batch 2 es
un error, no una adaptación.

---

## 3. Pregunta del Step 6

Una sola pregunta, se hace **una sola vez**, y solo si tras la detección (D-03) y el descarte por
fichero ya existente (D-05) queda al menos un agente candidato.

**VERBATIM**:

```
One last thing — want a shortcut for next time?

I can save a global setup-ai command so you can install this kit in any other repo without coming
back to the README. It's one small file, it lives outside this repo, and all it does is fetch these
same instructions fresh every time — nothing gets frozen or copied.

Where it'd go:

  - Claude Code — ~/.claude/commands/setup-ai.md, then run it with /setup-ai
  - Codex CLI — ~/.codex/skills/setup-ai/SKILL.md, then run it with $setup-ai

Yes or no? Either way, this repo is already set up.
```

**Reglas de sustitución** (lo único que se puede tocar del bloque):

- Deja **solo las líneas de los agentes candidatos**. Si el único candidato es Claude Code, la lista
  tiene una sola línea; ídem para Codex. Nunca se lista un agente cuyo directorio de usuario no
  existe o cuyo launcher ya existe.
- En la línea de Codex, si se está aplicando el fallback de D-04 (no existe `~/.codex/` pero sí
  `~/.agents/`), escribe `~/.agents/skills/setup-ai/SKILL.md` en lugar de la ruta primaria.
- Nada más se reescribe: ni el saludo, ni el párrafo del medio, ni el cierre.

**Reglas de comportamiento** (van en el Step 6, no dentro del bloque):

- Si no queda ningún candidato, **no se muestra este bloque en absoluto** y se salta al Wrap up
  (SC-004). No hay versión "informativa" de la pregunta.
- Un "no", un silencio o una respuesta ambigua se tratan **todos como no**: no se escribe nada fuera
  del repo y se continúa al Wrap up. A diferencia del Step 1, aquí **no** hay pregunta de reintento
  y nada queda bloqueado — la instalación del catálogo ya está hecha.
- La pregunta se hace después de que el catálogo esté instalado, nunca antes: el usuario debe poder
  decir que no sin perder nada.

---

## 4. Líneas del Wrap up

El launcher global va en **su propia sección**, después de `Installed` / `Updated` / `Skipped`,
porque es lo único que se escribe fuera del repo del usuario (B0-5). Cabecera de la sección:

```
Global launcher:
```

Se emite una línea por agente afectado. La sección **se omite entera** solo cuando no hay
absolutamente nada que decir: cuando se llegó aquí desde el launcher ya instalado (el Step 6 sale
antes de hacer nada) o cuando no se detectó ningún agente en el entorno.

### 4.1 — Instalado

**VERBATIM** (Claude / Codex):

```
- Saved ~/.claude/commands/setup-ai.md — from now on, just run /setup-ai in any repo.
```

```
- Saved ~/.codex/skills/setup-ai/SKILL.md — from now on, just run $setup-ai in any repo.
```

Sustituye la ruta de Codex por `~/.agents/skills/setup-ai/SKILL.md` si se usó el fallback (D-04).
Si el agente lo considera útil, puede añadir en la misma línea que quizá haya que reabrir la sesión
para que el comando aparezca — **opcional y solo esa coletilla**; el resto es literal.

### 4.2 — Ya existía, no se ha tocado (D-05)

**VERBATIM**:

```
- ~/.claude/commands/setup-ai.md was already there, so I left it exactly as it was — I never overwrite it. If that file isn't this kit's launcher, delete it and run the setup again to get the new one.
```

Misma línea para Codex cambiando la ruta. Esta línea **siempre se emite** cuando el fichero existe,
aunque no se haya preguntado nada: es el único aviso que recibe el usuario de que su `/setup-ai` no
es necesariamente el de este kit (R-01).

### 4.3 — El usuario ha dicho que no

**VERBATIM** (una sola línea, no una por agente):

```
- You said no, so nothing was written outside this repo. The README one-liner still works whenever you change your mind.
```

### 4.4 — Fallo de escritura (D-07)

**VERBATIM**:

```
- Couldn't write ~/.claude/commands/setup-ai.md — <the actual reason>. Everything in this repo installed fine; you're just missing the shortcut. Use the README one-liner next time, or fix that and run the setup again.
```

`<the actual reason>` es la razón real y concreta (`permission denied`, `~/.claude/ doesn't exist and
couldn't be created`, `disk full`…), nunca un "something went wrong" genérico — mismo criterio que la
categoría `Skipped` de L232. No se reintenta, no se buscan rutas alternativas, y **no se aborta ni
se revierte** la instalación del catálogo.

### 4.5 — Ejemplo completo de reporte (reemplaza el de `setup-ai.md` L239-251)

**VERBATIM**:

```
Done. Here's what happened:

Installed:
- .claude/commands/constitution.md
- .claude/agents/spec-writer.md

Updated:
- .claude/commands/plan.md (content had changed since last install)

Skipped:
- .claude/agents/legacy-reviewer.md — fetch failed twice (404), gave up after the retry

Global launcher:
- Saved ~/.claude/commands/setup-ai.md — from now on, just run /setup-ai in any repo.
```

---

## Cómo consume esto cada batch

- **Batch 1 · Step 6** — usa el §3 (pregunta + reglas de sustitución y de comportamiento). No usa
  todavía las plantillas.
- **Batch 1 · Wrap up** — usa el §4 completo, incluido el ejemplo de 4.5.
- **Batch 2 · Claude** — copia el §1 dentro de un bloque de código del Step 6, con la instrucción de
  escribirlo verbatim (mismo criterio byte-a-byte que el Step 4, L161-163). Las plantillas no
  contienen ningún ``` , así que un fence de tres backticks basta.
- **Batch 2 · Codex** — copia el §2 igual, más la nota de que aquí **no** hay traducción libre (a
  diferencia del Step 5) y de que la ruta es best-effort (U-01).
- **Batch 5 · Verificación** — compara carácter a carácter `setup-ai.md` contra este fichero.
  Divergencia = FAIL, incluso "mejoras" de redacción.

## Riesgos y puntos abiertos que quedan de este Batch 0

- **Sigue abierto U-01** (ruta global real de Codex). Este fichero fija el **texto**, no valida la
  ruta. La doc oficial dice `$HOME/.agents/skills/`; D-04 prioriza `~/.codex/skills/` por lo que hay
  en la máquina. Si se confirma lo contrario, cambian las rutas de §3 y §4, no el cuerpo de las
  plantillas.
- **`$ARGUMENTS` en la plantilla de Claude** es la única pieza que depende de una mecánica del
  agente (sustitución de argumentos en slash commands). Si en algún entorno no se sustituye, el
  agente lee la frase literal y la ignora — degradación limpia, no rotura. Riesgo bajo, aceptado.
- **Textos en inglés, interacción posiblemente en español.** Las skills del catálogo llevan un
  bloque `## Language` que obliga a responder en el idioma del usuario; `setup-ai.md` no lo lleva y
  sus preguntas están en inglés fijo. Se mantiene esa convención por coherencia con el Step 1; si en
  el futuro se decide localizar `setup-ai.md`, se localiza entero, no solo el Step 6. **Fuera de
  alcance de esta feature.**
- **La `description` del launcher es su propio trigger implícito.** Al llevar "install the toolkit",
  "instala el kit", etc., un agente podría auto-invocar el launcher sin que el usuario escriba
  `/setup-ai`. Es coherente con el resto del catálogo (todas las `description` de la casa listan
  triggers en lenguaje natural) y el launcher no destruye nada, así que se acepta.
