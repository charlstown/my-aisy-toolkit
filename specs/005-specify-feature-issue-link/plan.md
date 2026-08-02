# Plan — specify-feature debe incluir el link del issue de GitHub en requirements.md

Source: specs/005-specify-feature-issue-link/requirements.md

## Context gathered

- `ai-toolkit/default/commands/specify-feature.md` y `.claude/commands/specify-feature.md` son **byte-idénticos** en todo el rango Step 1 → Step 4 (verificado con diff dirigido). La única diferencia entre ambos ficheros en ese rango es una línea dentro de "Rules for filling it" (~L163) que compara con `grill-me`/`get-issues` — es la línea que toca la feature 002 (`002-remove-grill-me-from-default-profile`). El `Step 5` (resumen final) también diverge entre ambos ficheros por un motivo no relacionado (bloque de "next step" presente en uno, ausente en el otro) — no forma parte del alcance de esta feature.
- Referencias de línea en `ai-toolkit/default/commands/specify-feature.md` (idénticas en `.claude/commands/specify-feature.md`):
  - L17-48: `### Step 1 — Detect the input source`, con la tabla de clasificación en **1a** (L21-30), **1b** roadmap (L33-35), **1c** issues abiertos (L37-41), **1d** fallback (L43-48).
  - L50-59: `### Step 2 — Build the candidate list and confirm the selection`. Hoy normaliza a `{ title, raw_description, source }` (L52).
  - L61-68: `### Step 3 — Assign branch numbers and slugs` (no depende de tipo de fuente, solo de título/slug).
  - L70-166: `### Step 4 — Generate requirements.md …`, con el template fenced (L78-157) y "Rules for filling it" (L159-166).
  - L82: línea `Feature Branch: [NNN-feature-name]` dentro del template — punto de inserción del nuevo campo.
  - L168+: `### Step 5 — Summary` — **fuera de alcance** (ya diverge entre ambos ficheros por otra razón).
- **Compatibilidad con `clean-feature` (FR-005)**: `ai-toolkit/default/commands/clean-feature.md` Step 2.5 (L59) ya busca en `requirements.md`/`plan.md` los patrones `#\d+`, `issues/\d+`, `closes #\d+`, `fixes #\d+`, o un campo `issue:`. Una línea `Source Issue: https://github.com/{owner}/{repo}/issues/{n}` contiene literalmente la subcadena `issues/{n}`, que ya matchea `issues/\d+`. **No hace falta tocar `clean-feature.md`** — el nuevo campo simplemente hace esa detección determinista en vez de depender de que el número aparezca "por casualidad" en `Input: User description`.
- Los ficheros de ejemplo generados por este mismo skill (p. ej. `specs/002-remove-grill-me-from-default-profile/requirements.md`) mantienen las etiquetas `Feature Branch:`, `Created:`, `Status:`, `Input:` **siempre en inglés**, incluso cuando el resto del documento está en español. Esto es relevante para resolver la ambigüedad de FR-001 ("traducido si corresponde al idioma del usuario"): la convención real y verificable del repo no traduce estas etiquetas de metadatos.
- `Step 1a` ya captura owner/repo/n implícitamente vía el regex de la URL de issue único; `Step 1c` invoca `gh issue list --state open --json number,title,body,labels --limit 50` pero **no** captura owner/repo del repo actual — hace falta añadir esa captura (`gh repo view --json nameWithOwner` o equivalente) para poder construir la URL completa cuando el usuario elige un issue del listado.

## Decisions

**D-01 — Nuevo campo en el modelo normalizado del Step 2, no una estructura nueva.**
El objeto normalizado pasa de `{ title, raw_description, source }` a `{ title, raw_description, source, source_issue_url }`, con `source_issue_url = null` salvo que la fuente sea exactamente un issue de GitHub resuelto en 1a (URL de issue único) o 1c (elegido del listado de abiertos). Nunca se rellena para: archivos, roadmap (aunque una fila de roadmap referencie un issue), URLs genéricas, o prompts libres (Acceptance Scenario 3 / FR-004) — evita inventar o inferir.

**D-02 — Construcción de la URL.**
- Desde 1a (issue único): normalizar la URL ya capturada por el regex a la forma canónica `https://github.com/{owner}/{repo}/issues/{n}` (sin query string, fragment, ni slash final).
- Desde 1c (listado de abiertos): obtener `{owner}/{repo}` con `gh repo view --json nameWithOwner` (reutilizable también si 1c fue invocado por redirección desde la fila "URL de repo sin número de issue" de 1a) y `{n}` del campo `number` del issue elegido; construir la misma forma canónica.

**D-03 — Posición y etiqueta del campo en el template.**
Se inserta una línea `Source Issue: https://github.com/{owner}/{repo}/issues/{n}` inmediatamente después de `Feature Branch: [NNN-feature-name]` (L82) y antes de la línea en blanco previa a `Created:`, quedando claramente separada de `Input: User description:` (FR-003). La etiqueta `Source Issue:` se mantiene **en inglés siempre**, igual que `Feature Branch`, `Created`, `Status`, `Input` — se documenta explícitamente como decisión que prevalece sobre la lectura literal de FR-001 ("traducido si corresponde"), en favor de la convención real y verificable ya usada en los `requirements.md` existentes del repo.
Descartado: traducir la etiqueta según idioma del usuario — rompería la consistencia con las demás etiquetas de metadatos del mismo bloque.

**D-04 — Omisión limpia cuando no aplica.**
Cuando `source_issue_url` es `null`, la línea se omite por completo — no hay placeholder vacío, no hay `Source Issue: N/A`, no hay inferencia (FR-004, SC-002).

**D-05 — Sin cambios en `clean-feature.md`.**
FR-005 se satisface por construcción (D-02/D-03): el patrón `issues/\d+` que `clean-feature` ya busca matchea la nueva línea. Se añade una tarea de verificación (no de implementación) para confirmarlo explícitamente, en vez de modificar el regex de `clean-feature.md` sin necesidad.

**D-06 — Delimitación de alcance frente a la feature 002 (en curso).**
Los ficheros `ai-toolkit/default/commands/specify-feature.md` y `.claude/commands/specify-feature.md` son idénticos en Step 1-4 salvo la línea de "Rules for filling it" que compara con `grill-me`/`get-issues` (~L163) — esa línea es territorio exclusivo de la feature 002 y **no se toca** en este plan. La nueva regla sobre `Source Issue` se añade como un **bullet nuevo e independiente** en "Rules for filling it", sin reescribir ni reordenar el bullet existente de `grill-me`, para que ambos plans puedan mergear sin conflicto de líneas adyacentes. El `Step 5` (que ya diverge entre ambos ficheros por otro motivo, no relacionado con 002 ni con esta feature) tampoco se toca.

**D-07 — Sincronización de los dos ficheros.**
`ai-toolkit/default/commands/specify-feature.md` es la fuente canónica; `.claude/commands/specify-feature.md` recibe una copia mecánica idéntica de los mismos cambios (mismas líneas, mismo texto) en una tarea separada de sincronización, precedida de un diff dirigido a Step 1-4 para confirmar que no hay más divergencia que la ya documentada antes de aplicar.

## Batch 0 — Bloquear el diseño exacto del campo

- [x] @architect · Bloquear redacción exacta y puntos de inserción: A partir de las decisiones D-01 a D-05 de este plan, redactar el texto final y literal a insertar en `ai-toolkit/default/commands/specify-feature.md`: (a) la fila/nota añadida a la tabla de clasificación de **1a** (L21-30) indicando que para la fila "Single GitHub issue" se debe preservar `{owner}/{repo}/{n}` capturados por el regex, normalizando a `https://github.com/{owner}/{repo}/issues/{n}` sin query/fragment/slash final; (b) el texto añadido a **1c** (L37-41) indicando cómo obtener `{owner}/{repo}` vía `gh repo view --json nameWithOwner` (con fallback documentado si `gh` no está disponible: en ese caso `source_issue_url` queda `null` para las features detectadas por ese camino, no se inventa) y cómo combinarlo con el `number` del issue elegido; (c) la actualización de la frase de normalización del **Step 2** (L52) de `{ title, raw_description, source }` a `{ title, raw_description, source, source_issue_url }`, con la regla explícita de cuándo es `null`; (d) la línea nueva del template en **Step 4** (`Source Issue: https://github.com/{owner}/{repo}/issues/{n}` justo después de `Feature Branch:`, L82) y su condición de inclusión/omisión; (e) el bullet nuevo (no modificación de uno existente) a añadir en "Rules for filling it" (L159-166) documentando la regla de omisión sin inventar URLs. Entregar este texto como bloque literal listo para copiar/pegar en Batch 1, dejando explícito que no se toca ni la línea de `grill-me` (~L163) ni ninguna parte del `Step 5`.

## Batch 1 — Aplicar el cambio en el fichero canónico y sincronizar

- [x] @code-developer · Editar `ai-toolkit/default/commands/specify-feature.md`: aplicar literalmente el texto bloqueado en Batch 0 en los cinco puntos (tabla 1a, texto 1c, normalización Step 2, línea del template en Step 4, bullet nuevo en "Rules for filling it"). No modificar la línea existente sobre `grill-me`/`get-issues` (~L163) ni ninguna parte de `### Step 5 — Summary`. Confirmar visualmente que el nuevo campo queda entre `Feature Branch:` e `Input: User description:` en el bloque de template fenced, y que el resto del fichero permanece byte-idéntico salvo estas inserciones.
- [x] @code-developer · Sincronizar `.claude/commands/specify-feature.md`: antes de editar, correr un diff dirigido (Step 1 a Step 4, análogo al usado durante el discovery de este plan) entre ambos ficheros para confirmar que no hay más divergencia que la ya documentada (la línea de `grill-me`/`get-issues`). Aplicar exactamente los mismos cinco cambios del ficheros canónico, en las mismas posiciones relativas. Tras el cambio, el único diff restante entre ambos ficheros en el rango Step 1-4 debe ser esa única línea de `grill-me`/`get-issues`, y el `Step 5` sigue divergiendo solo por su motivo preexistente no relacionado.

## Batch 2 — Verificación

- [ ] @tester · Verificar los tres escenarios de aceptación por trazado del texto (no hay runtime ejecutable para un skill de instrucciones): **(1)** URL de issue único en 1a → confirmar que la tabla y el Step 4 producen instrucciones que resultan en una línea `Source Issue: https://github.com/{owner}/{repo}/issues/{n}` con URL completa, separada de `Input:`. **(2)** Issue elegido del listado de abiertos en 1c → confirmar que las instrucciones de captura de `{owner}/{repo}` vía `gh repo view` + `{n}` del issue elegido producen la misma línea. **(3)** Fuente no-issue (archivo, roadmap, prompt libre, URL genérica) → confirmar que las instrucciones dejan `source_issue_url = null` y que el Step 4 omite la línea sin placeholder. Reportar cualquier ambigüedad de redacción que permita a un agente ejecutor inventar una URL en el caso (3), y corregir la propuesta en cuyo caso se debe reabrir Batch 1 (no corregir el fichero directamente).
- [ ] @tester · Verificar FR-005 (compatibilidad con `clean-feature`) sin modificar código: confirmar leyendo `ai-toolkit/default/commands/clean-feature.md` L59 que el patrón `issues/\d+` ya usado por su extracción de `issue_num_{folder}` matchea la subcadena `issues/{n}` presente en la nueva línea `Source Issue:`. Confirmar además que ningún otro fichero (`.claude/commands/clean-feature.md`) necesita cambio para esto. No editar `clean-feature.md`.
- [ ] @tester · Verificar la delimitación de alcance frente a la feature 002: correr `git diff` sobre ambos ficheros `specify-feature.md` y confirmar que la única línea NO añadida por este plan que aparece modificada es cero (es decir, el diff de esta feature no toca la línea existente sobre `grill-me`/`get-issues` ni ninguna línea de `### Step 5 — Summary`). Reportar cualquier solape encontrado en vez de corregirlo.

## Batch 3 — Quality gate

- [ ] @judge · Revisar el diff completo de `ai-toolkit/default/commands/specify-feature.md` y `.claude/commands/specify-feature.md` contra `specs/005-specify-feature-issue-link/requirements.md`: confirmar FR-001 (campo explícito y etiquetado, justo debajo de `Feature Branch`), FR-002 (URL completa, no solo el número), FR-003 (separado de `Input: User description`), FR-004 (omitido sin inventar cuando no aplica), FR-005 (compatible con `clean-feature` sin cambios en ese fichero, verificado en Batch 2), FR-006 (ambos ficheros actualizados y con el mismo contenido salvo la divergencia preexistente documentada en D-06). Confirmar también que no se tocó la línea de `grill-me`/`get-issues` ni el `Step 5`. Emitir PASS o CHANGES_REQUESTED con fichero y línea exacta para cada hallazgo; si CHANGES_REQUESTED, devolver a @code-developer (Batch 1) para corregir.

### Critical Files for Implementation

- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\ai-toolkit\default\commands\specify-feature.md (fichero canónico — Step 1a L21-30, Step 1c L37-41, Step 2 L52, Step 4 template L78-157 y "Rules for filling it" L159-166)
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\.claude\commands\specify-feature.md (copia sincronizada — mismos puntos de inserción; NO tocar la línea de grill-me/get-issues ni el Step 5, que ya divergen por motivos ajenos a esta feature)
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\ai-toolkit\default\commands\clean-feature.md (solo lectura — confirma en Batch 2 que su regex `issues/\d+` en L59 ya es compatible con el nuevo campo, sin necesidad de editarlo)
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\specs\002-remove-grill-me-from-default-profile\requirements.md (solo lectura — delimita el territorio de la feature paralela que no debe pisarse)
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\specs\005-specify-feature-issue-link\requirements.md (fuente de los FR-001 a FR-006 y SC-001 a SC-003 que este plan implementa)
