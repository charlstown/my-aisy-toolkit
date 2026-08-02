# Plan — Encadenar la generación del roadmap al final de constitution

Feature Branch: `006-constitution-chain-roadmap`

Requirements: `specs/006-constitution-chain-roadmap/requirements.md`

Created: 2026-08-02

## 1. Contexto encontrado (verificado en el repo)

| Hallazgo | Evidencia |
|---|---|
| El fichero fuente canónico es `ai-toolkit/default/commands/constitution.md`; hoy tiene Step 0 (chequeo 2×2 de `product-spec.md`/`tech-spec.md`), Step 1 (`product-spec`), Step 2 (`tech-spec`) y Step 3 (resumen, con gating "solo si Steps 1 y 2 corrieron y ambos ficheros se confirmaron escritos") | Lectura completa del fichero |
| La copia instalada `.claude/commands/constitution.md` **ya estaba desincronizada antes de este issue**: tiene el mismo Step 0/1/2, pero su Step 3 es la versión antigua sin gating de éxito, sin bloque `✅ Done`, y con `Next: /roadmap to turn these into an execution plan.` en vez del bloque `✓ .../✅ Done/Suggested next step` | `diff` entre ambas copias — difieren líneas 1-70 vs 1-61 |
| `roadmap` (`ai-toolkit/default/commands/roadmap.md`) ya lee `specs/product-spec.md` y `specs/tech-spec.md` en paralelo en su propia Fase 0, y detecta PoCs en tech-spec por sí solo — no requiere que `constitution` le pase contexto | `ai-toolkit/default/commands/roadmap.md` § Phase 0 |
| `roadmap` tiene su **propia interview de 3 preguntas** (`AskUserQuestion` secuenciales: Fases, Tracking, Gates) más una confirmación de escritura en su Fase 2 — esto no se elimina ni se resume; `constitution` lo invoca "en su totalidad" (FR-005) | `ai-toolkit/default/commands/roadmap.md` § Phase 1-2 |
| `roadmap` ya termina con su propio bloque de cierre condicionado al éxito (`Show this block only when... specs/roadmap.md was actually written...`) seguido de `✅ Done. Suggested next step: 🎯 /specify-feature...` | `ai-toolkit/default/commands/roadmap.md` § Phase 4 |
| No existe ningún mecanismo automático de sincronización entre `ai-toolkit/default/` y `.claude/`; el propio `tech-spec.md` documenta que las copias se mantienen a mano (ADR-005 y "Known Limitations") | `specs/tech-spec.md` líneas 239-246, 292 |
| No hay tests automáticos ni CI para ficheros de skill; la estrategia de verificación documentada es manual, sobre un repo de scratch, o trazado lógico del texto de la instrucción | `specs/tech-spec.md` § Testing Strategy (líneas 139-156) |
| El plan lo consume `/implement-feature`: cada `##` es un batch, cada `- [ ]` una tarea, y hace un commit al cerrar cada batch | Convención observada en planes previos |

**Conclusión de alcance real:** el trabajo efectivo son **2 ficheros** (`ai-toolkit/default/commands/constitution.md` como fuente canónica, y `.claude/commands/constitution.md` como copia que debe terminar siendo idéntica). No se toca `roadmap.md`, `product-spec.md` ni `tech-spec.md` como skills (confirmado por el propio requirements en su sección de Assumptions).

## 2. Decisiones (ADR-style)

### D-01 — Se edita primero la fuente canónica completa; la copia `.claude/` se sincroniza al final, en un solo paso

**Decisión:** todos los cambios de contenido (Step 0, Step 3 nuevo, Step 4 renumerado) se aplican únicamente sobre `ai-toolkit/default/commands/constitution.md` en los Batches 1-3; un batch dedicado (Batch 4) copia el contenido final, verbatim, sobre `.claude/commands/constitution.md`.
**Alternativa descartada:** editar ambas copias en paralelo en cada batch.
**Por qué:** `.claude/commands/constitution.md` ya estaba desincronizado *antes* de este issue (ver §1) — editar ambas copias a la vez en cada batch duplicaría el riesgo de introducir una segunda divergencia a mitad de plan. Sincronizar en un único paso final, después de que el contenido canónico esté ya cerrado y validado, es más barato y verificable (un `diff` vacío) y de paso corrige la desincronización preexistente, cumpliendo FR-009 y SC-004 de una sola vez.

### D-02 — La tabla de Step 0 se generaliza a 8 filas (2³), pero sigue habiendo una única `AskUserQuestion` con las mismas 3 opciones

**Decisión:** la tabla de decisión pasa de 2×2 (4 combinaciones) a 3 columnas × 2 estados (8 combinaciones: `product-spec.md` / `tech-spec.md` / `roadmap.md`, cada uno Exists/Missing). La única fila que NO pregunta sigue siendo "los tres Missing" (bootstrap limpio). Las 7 filas restantes disparan la misma `AskUserQuestion` de siempre, solo que el texto de la pregunta y las opciones mencionan los tres ficheros.
**Alternativa descartada:** una pregunta distinta por combinación, o una pregunta separada solo para `roadmap.md`.
**Por qué:** el requirements (FR-001) solo pide que Step 0 "detecte también" `roadmap.md` e incluya el resultado en las opciones ya existentes; no pide una UX nueva. Mantener una única pregunta con 3 opciones (`Regenerar todo` / `Solo lo que falta` / `Cancelar`) conserva el patrón ya validado de `constitution` y evita explotar la complejidad conversacional.

### D-03 — "Solo lo que falta" se generaliza a una regla única: correr el Step N cuyo fichero correspondiente falte, en orden

**Decisión:** en vez de codificar el caso particular de FR-011 ("si solo falta roadmap.md, saltar directo a Step 3") como una rama especial, se redacta como consecuencia de una regla general: *"run only the steps below whose corresponding file is missing, in strict order (Step 1 for product-spec, Step 2 for tech-spec, Step 3 for roadmap), skipping any step whose file already exists"*, con el caso de FR-011 como ejemplo explícito dentro de esa regla.
**Alternativa descartada:** una tabla de casuística explícita para cada una de las 7 combinaciones con "solo lo que falta".
**Por qué:** una regla general es más corta, más fácil de mantener si en el futuro se añade un cuarto fichero a la cadena, y cubre exactamente el Edge Case del requirements sin necesitar enumerar los otros 6 subcasos por separado.

### D-04 — El fallo de Step 3 reutiliza el mismo mecanismo de "no mostrar resumen" que ya usa la ruta de Cancelar

**Decisión:** FR-010 (si `roadmap` falla o no escribe `specs/roadmap.md`, detenerse con error sin llegar al resumen) se implementa extendiendo la condición ya existente en el actual Step 3/nuevo Step 4 ("Show this block only when the run finished successfully... If the run ended any other way... show nothing") para que también contemple el fallo de Step 3, en vez de inventar un mecanismo de manejo de errores nuevo.
**Alternativa descartada:** un bloque de error explícito con formato propio (`❌ Error: ...`).
**Por qué:** el requirements no especifica el texto exacto del error, solo que debe informarse al usuario y no debe llegar al resumen final. Reutilizar la convención ya presente en el fichero (que ya distingue "resumen visible" vs "nada, sin bloque") es la implementación de menor superficie y más coherente con el resto del documento.

### D-05 — Verificación sin runtime: diff mecánico + trazado lógico de escenarios, no una ejecución real de `/constitution`

**Decisión:** dado que no hay tooling automatizado para ficheros de skill (confirmado en `tech-spec.md` § Testing Strategy), la tarea de `@tester` en el Batch 4 se limita a (a) un `diff` de ambas copias del fichero (debe ser vacío) y (b) un trazado manual, escenario por escenario, de cada Acceptance Scenario y Edge Case del `requirements.md` contra el texto final de la instrucción — sin invocar `/constitution` de verdad, porque eso requiere una sesión viva de Claude Code fuera del alcance de las herramientas del subagente tester.
**Alternativa descartada:** exigir una ejecución real de `/constitution` en un repo de scratch como parte del plan.
**Por qué:** coherente con la Testing Strategy ya documentada en el repo ("No persistent automated tooling... Manual verification remains the repeatable process"). Pedir una ejecución real excede lo que el rol `@tester` puede hacer con sus herramientas (`Read, Grep, Glob, Bash, Write`, sin acceso a invocar otras skills).

## 3. Plan por batches

Orden por prioridad de historias: P1 → P1 → P2 → sincronización → gate. Cada batch cierra con un commit (lo hace `/implement-feature`).

### Batch 1 — P1 · Step 0 detecta también roadmap.md (User Story 2)

- [x] @code-developer · Ampliar Step 0 de constitution.md a las tres specs: en `D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\ai-toolkit\default\commands\constitution.md`, sustituir por completo la sección `### Step 0 — Check what already exists` (desde ese encabezado hasta el final del párrafo que termina en "...or to `/clean-feature` if the specs are just out of sync with completed work.", justo antes de `### Step 1 — Run `product-spec``) por una versión que: (1) usa `Glob` para comprobar `specs/product-spec.md`, `specs/tech-spec.md` **y** `specs/roadmap.md`; (2) reemplaza la tabla 2×2 actual por una tabla de 8 filas (todas las combinaciones Exists/Missing de los tres ficheros), donde la única fila que no pregunta es "Missing / Missing / Missing" → "Go straight to Step 1 (run all three, no question needed)", y las 7 restantes dicen "Ask (see below)" con una nota breve de qué Step falta probablemente en cada caso; (3) la `AskUserQuestion` menciona los tres ficheros en la pregunta ("product-spec.md, tech-spec.md and/or roadmap.md already exist. What do you want to do?") y ajusta la descripción de las opciones `Regenerate all from scratch` / `Only run what's missing` / `Cancel` para nombrar los tres ficheros/skills; (4) si el usuario cancela, se detiene igual que hoy; (5) si elige "Only run what's missing" y los tres ficheros ya existen, informa que no hay nada que bootstrapear y apunta a `/product-spec`, `/tech-spec` o `/roadmap` directamente (o a `/clean-feature`), igual que hoy pero mencionando también `/roadmap`; (6) añade un párrafo nuevo que generaliza "Only run what's missing" como regla: correr solo los Steps cuyo fichero correspondiente falte, en orden estricto (Step 1 → product-spec, Step 2 → tech-spec, Step 3 → roadmap), saltando cualquier Step cuyo fichero ya exista, con el ejemplo explícito "if only `specs/roadmap.md` is missing, skip straight to Step 3 without re-running Steps 1 or 2." Cubre FR-001 y FR-011; ver decisiones D-02 y D-03.

### Batch 2 — P1 · Encadenar roadmap como Step 3 automático (User Story 1)

- [x] @code-developer · Actualizar frontmatter y Purpose para reflejar la cadena de 3 skills: en el mismo fichero, en el bloque frontmatter (`description:`) y en el párrafo bajo `## Purpose`, actualizar el texto para que mencione que `constitution` ahora encadena `product-spec` → `tech-spec` → `roadmap` (hoy solo menciona los dos primeros). No cambiar el nombre del skill ni los triggers de invocación ("constitution", "constitución", etc.), solo extender la descripción de qué hace. El párrafo de Purpose debe seguir dejando claro que `constitution` es "a thin orchestrator" que no entrevista por sí mismo, y añadir que `roadmap`'s own Phase 0 reads both `specs/product-spec.md` and `specs/tech-spec.md` on its own, igual que ya se explica para `tech-spec` leyendo `product-spec.md`.
- [x] @code-developer · Insertar el nuevo Step 3 (`roadmap`) entre el Step 2 actual y el resumen: en el mismo fichero, insertar una nueva sección `### Step 3 — Run \`roadmap\`` inmediatamente después de la sección `### Step 2 — Run \`tech-spec\`` y antes de la actual `### Step 3 — Summary`. El contenido debe indicar: (a) salvo que Step 0 haya determinado que `specs/roadmap.md` ya existe y debe conservarse, correr el skill `roadmap` ahora, en su totalidad (su propia interview de 3 preguntas, su propia escritura de fichero); (b) no presentar ningún `AskUserQuestion` propio de `constitution` antes o después de invocar `roadmap` — la entrevista completa es de `roadmap`; (c) `roadmap`'s own Phase 0 lee `specs/product-spec.md` y `specs/tech-spec.md` escritos (o ya presentes) en los Steps 1-2 por sí solo — no pasárselos manualmente ni resumir su contenido; (d) esperar a que `roadmap` termine por completo y confirmar que `specs/roadmap.md` fue escrito antes de continuar; (e) si el skill `roadmap` falla, es cancelado, o de cualquier forma no llega a escribir `specs/roadmap.md`, detenerse aquí: informar del fallo al usuario y no continuar al resumen del Step 4. Cubre FR-002, FR-003, FR-004, FR-005 y FR-010; ver decisiones D-01 (no aplica aquí) y D-04.
- [x] @code-developer · Renumerar la sección de resumen de Step 3 a Step 4: en el mismo fichero, cambiar el encabezado `### Step 3 — Summary` (el que queda después del nuevo Step 3 insertado) a `### Step 4 — Summary`, sin tocar todavía el contenido interior de esa sección (eso lo hace el Batch 3). Actualizar también la sección `## Constraints` al final del fichero: en el primer bullet (`**Strictly sequential.**`), extender la frase para incluir `roadmap` ("Never run `product-spec`, `tech-spec`, and `roadmap` in parallel — ... and `roadmap` depends on reading both finished `product-spec.md` and `tech-spec.md`"); en el segundo bullet (`**No interview of its own.**`), añadir `roadmap` a la lista de skills que aportan las preguntas; en el tercer bullet (`**Do not skip Step 0's check.**`), añadir `roadmap.md` a la lista de ficheros que no deben sobrescribirse sin preguntar; y añadir un cuarto bullet nuevo `**Stop on Step 3 failure.**` que indique que si `roadmap` falla en escribir `specs/roadmap.md`, hay que detenerse con error, no mostrar el resumen del Step 4, y no reintentar `roadmap` automáticamente. Cubre FR-004 (constraint de orden), FR-010 (constraint de fallo).

### Batch 3 — P2 · Resumen final actualizado (User Story 3)

- [x] @code-developer · Reescribir el cuerpo del Step 4 — Summary: en el mismo fichero, dentro de la sección `### Step 4 — Summary` (renumerada en el Batch 2), sustituir la condición de "cuándo mostrar el bloque" para que también contemple el Step 3: el bloque solo se muestra cuando todos los Steps que debían correr (según lo decidido en Step 0) corrieron y cada fichero correspondiente — incluyendo `specs/roadmap.md` del Step 3 — fue confirmado escrito; si el run terminó de cualquier otra forma (Cancelar en Step 0, nada que bootstrapear, o fallo del Step 3 per Batch 2), no mostrar nada. Sustituir el bloque de cierre actual por: `✓ specs/product-spec.md`, `✓ specs/tech-spec.md`, `✓ specs/roadmap.md`, línea en blanco, `✅ Done. Suggested next step:`, línea en blanco, y una única línea `🎯 /specify-feature to turn what you want to build next into a feature spec.` — eliminando por completo la línea `🗺️ /roadmap (optional) to turn the specs into a phased plan. Skip it if you already know what comes first.` que hoy sugiere correr `/roadmap` manualmente. Mantener la frase "Write the block in the user's language... Keep the skill names (...) and the emojis exactly as they are..." pero ajustar la lista de nombres de skill mencionados para que solo cite `/specify-feature` (ya no hace falta mencionar `/roadmap` como nombre a preservar, dado que ya no aparece en el bloque). Mantener intacta la última frase ("This block only suggests. Do not run the suggested skill yourself..."). Cubre FR-006, FR-007 y FR-008.

### Batch 4 — Sincronizar copias y verificar

- [ ] @code-developer · Sincronizar la copia instalada del skill: copiar el contenido completo y final de `D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\ai-toolkit\default\commands\constitution.md` (tras los Batches 1-3) sobre `D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\.claude\commands\constitution.md`, reemplazando su contenido íntegro para que ambos ficheros queden byte-idénticos. Esto también corrige la desincronización preexistente descrita en el §1 (la copia `.claude/` tenía un Step 3/Summary antiguo, previo a este issue, que nunca se había alineado con el formato `✅ Done` ya usado en la copia canónica). Cubre FR-009 y SC-004; ver decisión D-01.
- [ ] @tester · Verificar sincronización y trazar los escenarios de aceptación: (a) ejecutar un `diff` entre `ai-toolkit/default/commands/constitution.md` y `.claude/commands/constitution.md` y confirmar que es vacío (FR-009, SC-004); (b) trazar manualmente, línea por línea del fichero final, cada uno de los Acceptance Scenarios de las 3 User Stories del `requirements.md` (incluidos los 2 Edge Cases) y reportar PASS/FAIL con la cita textual del fragmento del fichero que sustenta cada uno — en particular: que Step 0 lista las 8 combinaciones y detecta ausencia de `roadmap.md` (US2, Escenarios 1-2); que no hay ningún `AskUserQuestion` de `constitution` entre el fin del Step 2 y el inicio del Step 3 (US1, Escenario 1); que el Step 3 espera la finalización completa de `roadmap` y confirma la escritura de `specs/roadmap.md` antes de continuar (US1, Escenario 2); que el resumen final lista los 3 `✓` y ya no sugiere `/roadmap` manual, con el siguiente paso siendo únicamente `/specify-feature` (US3, Escenarios 1-2); que un fallo de `roadmap` en Step 3 detiene la ejecución sin llegar al resumen (Edge Case 1); y que "solo lo que falta" con únicamente `roadmap.md` ausente salta directo a Step 3 sin re-ejecutar Steps 1-2 (Edge Case 2). Si algún escenario no queda sustentado por el texto, reportarlo como FAIL con la cita exacta del problema; no corregir nada. Ver decisión D-05.

### Batch 5 — Quality gate

- [ ] @judge · Quality gate de la feature: revisar de forma independiente los 2 ficheros tocados (`ai-toolkit/default/commands/constitution.md` y `.claude/commands/constitution.md`) contra `specs/006-constitution-chain-roadmap/requirements.md`, verificando en particular: que las 11 Functional Requirements (FR-001 a FR-011) están cubiertas por el texto final; que Step 0, Step 3 y Step 4 mantienen el estilo y las convenciones ya presentes en el resto del fichero (mismo formato de tabla, mismo patrón de `AskUserQuestion`, mismo idioma inglés de las instrucciones); que el orden estrictamente secuencial `product-spec → tech-spec → roadmap` queda explícito tanto en el flujo como en `## Constraints`; que el bloque de resumen final ya no menciona `/roadmap` como paso manual opcional; y que ambas copias del fichero son idénticas (confirmando el resultado del `diff` del Batch 4). Emitir PASS o CHANGES_REQUESTED con la lista concreta de correcciones si aplica.

## 4. Dependencias entre batches

```
Batch 1 (Step 0 detecta roadmap.md)
        │
        ▼
Batch 2 (Step 3 nuevo + renumerado a Step 4 + Constraints)
        │
        ▼
Batch 3 (cuerpo del Step 4 reescrito)
        │
        ▼
Batch 4 (sync .claude/ + verificación)
        │
        ▼
Batch 5 (quality gate)
```

- Los Batches 1, 2 y 3 editan **el mismo fichero canónico** de forma acumulativa: Batch 2 depende de que Batch 1 ya haya dejado Step 0 con las 8 combinaciones (el texto de "only what's missing" que Batch 2 referencia en su Step 3 fue escrito en Batch 1); Batch 3 depende de que Batch 2 ya haya insertado y renumerado el Step 4 que Batch 3 reescribe por dentro. **Deben ejecutarse en ese orden estricto, nunca en paralelo entre sí.**
- Batch 4 exige que 1, 2 y 3 estén cerrados (necesita el contenido canónico final para copiarlo). Las dos tareas de Batch 4 son secuenciales entre sí (la de `@tester` necesita que la sincronización de `@code-developer` ya se haya hecho para poder comparar).
- Batch 5 exige que el 4 esté cerrado.

## 5. Propuestas fuera del alcance (NO ejecutar en esta feature)

1. **Modificar el skill `roadmap.md` en sí** (por ejemplo, para que reciba contexto pre-resumido de `constitution`). Explícitamente descartado por las Assumptions del `requirements.md`: `roadmap` ya lee `product-spec.md` y `tech-spec.md` por sí mismo.
2. **Automatizar la sincronización entre `ai-toolkit/default/` y `.claude/`** con un script o hook de pre-commit. El propio `tech-spec.md` ya documenta esta ausencia como limitación conocida y no es parte de este issue; se mitiga aquí solo para este fichero puntual (Batch 4), no de forma general.
3. **Unificar el frontmatter de `constitution.md`** (`description:` suelto) al formato de `roadmap.md` (`name:` + `description:` + `when_to_use:`). Es una inconsistencia preexistente entre skills, no relacionada con este issue.

## 6. Riesgos y desconocidos abiertos

| # | Riesgo / desconocido | Impacto | Mitigación / estado |
|---|---|---|---|
| R-01 | `roadmap` conserva su propia entrevista de 3 preguntas (`AskUserQuestion` secuenciales); `/constitution` no queda 100% desatendido de principio a fin, solo sin *confirmación intermedia* entre Step 2 y Step 3 | Podría malinterpretarse como "constitution ahora es totalmente automático" | Es el comportamiento pedido explícitamente por FR-005 ("se invoca en su totalidad... sin que constitution le pase contexto manualmente"); no es un defecto, pero conviene que el Batch 2 no prometa en el Purpose algo distinto de esto |
| R-02 | La copia `.claude/commands/constitution.md` tenía una desincronización preexistente al issue (Step 3 antiguo sin gating de éxito) | Si el Batch 4 se salta o se hace mal, el repo queda con la copia instalada mostrando comportamiento distinto al canónico | El `diff` vacío del Batch 4 (`@tester`) es la comprobación mecánica que lo detecta sin ambigüedad |
| R-03 | No hay forma de invocar `/constitution` de extremo a extremo dentro de este plan (requiere una sesión viva de Claude Code, fuera de las herramientas de `@tester`) | La verificación queda en trazado lógico de texto, no en ejecución real | Aceptado explícitamente en D-05, coherente con la Testing Strategy ya documentada en `tech-spec.md` |
| U-01 | ¿Debe `constitution` seguir soportando el caso "solo tech-spec y roadmap faltan" (product-spec existe) corriendo Step 2 y Step 3 pero no Step 1? | Bajo: ya cubierto por la regla general de D-03, no requiere código especial | No bloquea ninguna tarea del plan; la regla general del Batch 1 ya lo resuelve sin ambigüedad |

### Critical Files for Implementation
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\ai-toolkit\default\commands\constitution.md
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\.claude\commands\constitution.md
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\ai-toolkit\default\commands\roadmap.md
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\specs\006-constitution-chain-roadmap\requirements.md
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\specs\tech-spec.md
