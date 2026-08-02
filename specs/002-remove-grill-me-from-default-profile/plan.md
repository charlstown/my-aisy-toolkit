# Plan — Eliminar grill-me del catálogo de skills y de la instalación por defecto

Feature Branch: `002-remove-grill-me-from-default-profile`

Requirements: `specs/002-remove-grill-me-from-default-profile/requirements.md`

Created: 2026-08-02

## 1. Contexto encontrado (verificado en el repo)

| Hallazgo | Evidencia |
|---|---|
| `catalog.yaml` solo declara un perfil, `default`, y `grill-me.md` es la línea 11 de su lista `commands` | `catalog.yaml` líneas 1-14 |
| Los ficheros fuente existen en ambas ubicaciones que pide el requirements | `ai-toolkit/default/commands/grill-me.md` y `.claude/commands/grill-me.md` (139 líneas cada uno, no son byte-idénticos pero sí funcionalmente equivalentes) |
| `.claude/commands/` es la copia instalada localmente para desarrollar el propio toolkit, no el catálogo distribuible | `ai-toolkit/default/README.md` línea 166: *"Internal only... used to develop the toolkit itself (not distributed)"* |
| `specify-feature.md` menciona `grill-me` dos veces, **en ambas copias** (`ai-toolkit/default/commands/` y `.claude/commands/`), y el texto **no es idéntico** entre copias en la segunda mención | línea 11 idéntica en ambas copias; línea ~162 difiere: la copia `.claude/` añade una cláusula extra sobre `get-issues` que la copia `ai-toolkit/default/` no tiene |
| `clarify-feature.md` menciona `grill-me` dos veces en ambas copias, y el requirements (FR-011) pide **dejarlas tal cual** | `ai-toolkit/default/commands/clarify-feature.md` líneas 11 y 125; `.claude/commands/clarify-feature.md` líneas 11 y 111 |
| `README.md` y `README-ES.md` listan `/grill-me` en la tabla de skills **y además** cuentan "11 skills" en dos sitios cada uno | README.md líneas 59, 87, 114; README-ES.md líneas 59, 87, 114 |
| `specs/product-spec.md` lista `/grill-me` en su tabla de skills y repite "11 skills" en el árbol de estructura | líneas 125 y 171 |
| `setup-ai.md` repite el conteo "11 skills, 6 agents" como ejemplo del prompt de selección de perfil | línea 87 |
| `CHANGELOG.md` solo menciona `grill-me` dentro de la entrada histórica `## [0.1.0] - 2026-08-01`, ya publicada, que documenta lo que existía en esa versión | líneas 8-19 |
| **Hallazgo no listado explícitamente en el requirements pero directamente dentro de su alcance**: `ai-toolkit/default/README.md` (la documentación detallada del catálogo del perfil `default`, distinta de `README.md` raíz) dedica una fila de tabla completa a `/grill-me`, una frase narrativa ("Nine of the eleven skills... the remaining two (`new-issue`, `grill-me`)...") y dos menciones comparativas más, calcadas de las de `specify-feature.md`/`clarify-feature.md` | `ai-toolkit/default/README.md` líneas 26, 50, 110, 117 |
| No existe ningún workflow de CI ni script que valide automáticamente la paridad entre `catalog.yaml` y los ficheros instalados | no se encontró `.github/workflows/`; único mecanismo de verificación es manual/@tester |

**Conclusión de alcance real:** los FR-001 a FR-003 y FR-008/FR-009 (catálogo + ficheros físicos + comportamiento de `setup-ai`) se resuelven con 2 ediciones y 2 borrados. Los FR-004 a FR-007 (documentación) tocan 4 ficheros explícitos, pero para que la feature no deje una inconsistencia flagrante justo al lado (mismo tipo de tabla, mismo conteo de skills) se añade `ai-toolkit/default/README.md` y `setup-ai.md` como consecuencia directa de la misma corrección documental — no como ampliación de alcance funcional (ver decisión D-02).

## 2. Decisiones

### D-01 — `CHANGELOG.md`: no se reescribe la entrada histórica `[0.1.0]`; se añade una entrada nueva bajo `[Unreleased]`

**Decisión:** se añade una sección `### Removed` bajo `## [Unreleased]` documentando la baja de `grill-me` del perfil `default`. La entrada `## [0.1.0] - 2026-08-01` **no se toca**.
**Alternativa descartada:** editar la lista de skills dentro de la entrada `[0.1.0]` para quitar `grill-me` de ella.
**Por qué:** Keep a Changelog (que el propio fichero declara seguir) trata cada entrada de versión como un registro histórico de lo que se publicó en ese momento; `grill-me` sí formaba parte del catálogo en la `0.1.0` real, así que borrarlo de esa entrada falsearía el historial. FR-006 permite "actualizar o eliminar referencias" — se interpreta como: actualizar el registro *hacia adelante* (nueva entrada), sin reescribir el pasado. Esto satisface la intención de SC-003 (que el changelog no represente a `/grill-me` como disponible *hoy*) sin violar la convención del propio formato que el fichero ya sigue.

### D-02 — Se incluyen `ai-toolkit/default/README.md` y `setup-ai.md` aunque el requirements no los lista por nombre

**Decisión:** se corrigen también estos dos ficheros.
**Alternativa descartada:** limitarse estrictamente a los 4 ficheros nombrados en FR-004–FR-007.
**Por qué:** `ai-toolkit/default/README.md` es la documentación detallada del mismo catálogo que `README.md`/`README-ES.md` resumen, con una fila de tabla y una frase narrativa dedicadas a `/grill-me` como skill disponible — dejarlo intacto contradice directamente el objetivo declarado del issue (SC-003) y crea una inconsistencia inmediata entre dos documentos que describen el mismo catálogo. `setup-ai.md` solo tiene un conteo numérico de ejemplo ("11 skills, 6 agents") que queda obsoleto en cuanto el catálogo pasa a 10 skills; es una corrección mecánica de una línea, mismo tipo de cambio que ya se hace en README.md/README-ES.md/product-spec.md por el mismo motivo (conteos de skills).

### D-03 — Los conteos "11 skills"/"eleven skills" se corrigen a "10" en la misma tarea que edita cada fichero

**Decisión:** cada tarea que quita la fila `/grill-me` de una tabla también corrige, en el mismo fichero, cualquier conteo numérico de skills que quede desincronizado ("11 skills" → "10 skills", "eleven" → "ten").
**Por qué:** son la misma clase de inconsistencia documental que las FR ya piden corregir; dejarlas produciría un catálogo documentado con dos números distintos (la tabla con 10 filas, el resumen diciendo 11) en el mismo fichero.

### D-04 — Las menciones comparativas a `grill-me` en `specify-feature.md` se resuelven quitando la cláusula comparativa, no reescribiendo toda la frase

**Decisión:** en la línea 11 de ambas copias (idéntica), se quita únicamente "Unlike `grill-me`, " del inicio de la frase, dejando el resto intacto. En la segunda mención (~línea 162), se quita la frase final que compara con `grill-me`, conservando (en la copia `.claude/`) la cláusula que compara con `get-issues`, que sigue siendo válida y no debe eliminarse.
**Por qué:** FR-010 pide "ajustar o eliminar" la mención comparativa, no reescribir la skill entera. El texto resultante debe seguir siendo gramaticalmente correcto y no perder la comparación con `get-issues` (que no es objeto de esta feature). Esto exige tratar las dos copias como ediciones independientes porque su segunda mención no es idéntica hoy.
**`clarify-feature.md` no se toca en ninguna copia** (FR-011, decisión ya cerrada en el requirements).

## 3. Plan por batches

Orden: primero el catálogo y los ficheros físicos (lo único con efecto funcional real en `setup-ai`), luego las menciones cruzadas en otras skills, luego documentación, luego verificación y gate.

### Batch 1 — P1 · Catálogo y ficheros físicos de la skill (User Story 1 y 2)

- [x] @code-developer · Quitar `grill-me` del perfil default en catalog.yaml: en `D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\catalog.yaml`, eliminar la línea `      - ai-toolkit/default/commands/grill-me.md` (línea 11, dentro de `profiles.default.commands`). No tocar ninguna otra línea, ni el bloque `agents`, ni el orden del resto de comandos. Cubre FR-001 y SC-001.
- [x] @code-developer · Borrar los dos ficheros fuente de la skill grill-me: eliminar `D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\ai-toolkit\default\commands\grill-me.md` y `D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\.claude\commands\grill-me.md` del árbol del repo (borrado físico, no solo del índice de git — debe reflejarse como eliminación en `git status`). No borrar ningún otro fichero de `commands/`. Cubre FR-002, FR-003 y SC-002.

### Batch 2 — P1 · Menciones comparativas en otras skills (FR-010, FR-011)

- [x] @code-developer · Ajustar la mención comparativa a grill-me en specify-feature.md (ambas copias): en `D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\ai-toolkit\default\commands\specify-feature.md` y en `D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\.claude\commands\specify-feature.md`: (a) en la línea 11 de ambos ficheros, quitar el prefijo `Unlike \`grill-me\`, ` dejando el resto de la frase intacto — debe quedar "This skill never interrogates the user to resolve ambiguity: it writes down what it has and evidences everything unclear in a `DEFINITION GAP` section for the user to resolve later."; (b) en la segunda mención (línea ~162 en ambos), quitar la cláusula final que compara con `grill-me`. En la copia `ai-toolkit/default/`, la frase queda cortada en "...instead of being guessed at." (se elimina la frase siguiente completa sobre `grill-me`). En la copia `.claude/`, se conserva la cláusula sobre `get-issues` y solo se quita la parte de `grill-me`, quedando: "This is the key difference from `get-issues`' `Decision gap` (which blocks planning) — `specify` just documents the gap and moves on." No tocar `clarify-feature.md` en ninguna copia (FR-011, sin cambios). Cubre FR-010.

### Batch 3 — P2 · Documentación (User Story 3 + consistencia directa, decisiones D-02/D-03)

- [x] @code-developer · Actualizar README.md: en `D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\README.md`, eliminar la fila `| \`/grill-me\` | ... |` de la tabla de skills (línea 87) y corregir "11 skills" → "10 skills" en las líneas 59 y 114. No tocar el resto de filas, ni la tabla de agentes, ni ninguna otra sección. Cubre FR-004 y parte de SC-003.
- [x] @code-developer · Actualizar README-ES.md: mismo cambio que la tarea anterior en `D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\README-ES.md` (eliminar fila `/grill-me` en línea 87, corregir "11 skills" → "10 skills" en líneas 59 y 114, respetando el texto en español ya existente). Cubre FR-005 y parte de SC-003.
- [x] @code-developer · Actualizar specs/product-spec.md: en `D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\specs\product-spec.md`, eliminar la fila `/grill-me` de la tabla de skills (línea 125) y corregir "11 skills" → "10 skills" en el árbol de estructura de proyecto (línea 171). Cubre FR-007 y parte de SC-003.
- [x] @code-developer · Añadir entrada Removed en CHANGELOG.md sin tocar el histórico: en `D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\CHANGELOG.md`, bajo la sección existente `## [Unreleased]` (línea 8), añadir una subsección `### Removed` con una entrada del tipo: "`grill-me` skill removed from the `default` profile catalog (10 skills now, down from 11); its source files (`ai-toolkit/default/commands/grill-me.md`, `.claude/commands/grill-me.md`) were deleted. Existing installs that already had `/grill-me` are unaffected — `setup-ai` never uninstalls skills a repo already has." **No modificar la entrada `## [0.1.0] - 2026-08-01` existente** (decisión D-01: es un registro histórico y no se reescribe). Cubre FR-006 y parte de SC-003.
- [x] @code-developer · Actualizar ai-toolkit/default/README.md (decisión D-02): en `D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\ai-toolkit\default\README.md`: (a) en la línea 26, corregir la frase "Nine of the eleven skills form one closed sequential workflow... The remaining two (`new-issue`, `grill-me`) are standalone utilities..." para reflejar que ahora quedan 10 skills y que la única utilidad independiente restante es `new-issue` (ajustar la gramática de plural a singular en consecuencia); (b) eliminar la fila de tabla dedicada a `/grill-me` (línea 50); (c) en las líneas 110 y 117, quitar las cláusulas comparativas con `grill-me` siguiendo el mismo criterio que en el Batch 2 (conservar el resto de cada frase intacto). Este fichero no está en la lista explícita de FR-004–FR-007, pero es la documentación detallada del mismo catálogo y queda directamente dentro del espíritu de SC-003 (ver decisión D-02).
- [x] @code-developer · Corregir el conteo de ejemplo en setup-ai.md (decisión D-02): en `D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\setup-ai.md`, línea 87, corregir "1. default — 11 skills, 6 agents" → "1. default — 10 skills, 6 agents". No tocar el resto del bloque de ejemplo ni la lógica de preguntas.

### Batch 4 — Verificación (todas las User Stories)

- [ ] @tester · Verificar la eliminación funcional y física (FR-001–FR-003, FR-008, SC-001, SC-002, SC-004): confirmar que `catalog.yaml` no contiene ninguna ocurrencia de `grill-me.md`; confirmar que `ai-toolkit/default/commands/grill-me.md` y `.claude/commands/grill-me.md` no existen en el árbol de trabajo; simular una instalación de `setup-ai` con el perfil `default` (leyendo `catalog.yaml` y copiando los ficheros que declara a una carpeta de prueba) y confirmar que no se produce ningún fichero `grill-me.md` ni un comando `/grill-me`, satisfaciendo SC-004. Reportar cualquier discrepancia con evidencia (ruta y línea).
- [ ] @tester · Verificar la documentación y las referencias cruzadas (FR-004–FR-007, FR-010, FR-011, SC-003): buscar `grill-me` en todo el repo y confirmar que las únicas coincidencias restantes son (a) las menciones intencionalmente conservadas en `clarify-feature.md` (ambas copias, FR-011) y (b) las referencias dentro de esta propia carpeta `specs/002-remove-grill-me-from-default-profile/` (requirements.md y plan.md, que documentan el cambio); confirmar que `README.md`, `README-ES.md`, `specs/product-spec.md` y `ai-toolkit/default/README.md` ya no listan `/grill-me` como skill disponible y que sus conteos de skills dicen "10"; confirmar que `CHANGELOG.md` tiene la nueva entrada `Removed` bajo `[Unreleased]` y que la entrada `[0.1.0]` sigue intacta (no editada). Reportar cualquier mención residual no contemplada.

### Batch 5 — Quality gate

- [ ] @judge · Quality gate de la feature: revisar de forma independiente todos los ficheros tocados (`catalog.yaml`, ambas copias de `grill-me.md` borradas, ambas copias de `specify-feature.md`, `README.md`, `README-ES.md`, `CHANGELOG.md`, `specs/product-spec.md`, `ai-toolkit/default/README.md`, `setup-ai.md`) contra `specs/002-remove-grill-me-from-default-profile/requirements.md` (FR-001 a FR-011, SC-001 a SC-004). Verificar en particular: que `clarify-feature.md` no fue modificado en ninguna copia (FR-011); que la entrada histórica `[0.1.0]` de `CHANGELOG.md` sigue sin cambios (decisión D-01); que ninguna edición introdujo lógica de desinstalación activa en `setup-ai.md` (FR-009 — el alcance es exclusivamente no reinstalar, nunca borrar instalaciones previas); que las dos copias de `specify-feature.md` quedan gramaticalmente correctas tras quitar la cláusula de `grill-me`; y que no queda ninguna fila de tabla, conteo o mención sin corregir. Emitir PASS o CHANGES_REQUESTED con la lista concreta de correcciones si aplica.

## 4. Dependencias entre batches

```
Batch 1 (catalog.yaml + borrado de ficheros)
        │
        ▼
Batch 2 (ajustar specify-feature.md, ambas copias)
        │
        ▼
Batch 3 (README, README-ES, CHANGELOG, product-spec, ai-toolkit/default/README, setup-ai.md)
        │
        ▼
Batch 4 (verificación funcional + documental)  ──►  Batch 5 (quality gate)
```

- Las 2 tareas del **Batch 1** son independientes entre sí.
- Las 6 tareas del **Batch 3** son independientes entre sí (ficheros distintos) y pueden ejecutarse en cualquier orden o en paralelo.
- **Batch 4** exige que 1, 2 y 3 estén cerrados; **Batch 5** exige el 4.

## 5. Riesgos y consideraciones fuera de alcance

| # | Riesgo / consideración | Impacto | Mitigación / estado |
|---|---|---|---|
| R-01 | Repos ya instalados con `/grill-me` de una versión anterior no se ven afectados por este cambio (por diseño, FR-009) | Ninguno funcional; es el comportamiento deseado | Ya cubierto por el edge case del requirements; el Batch 5 verifica que no se introduce lógica de desinstalación activa |
| R-02 | El título de la PR que cierre esta feature debe llevar el prefijo correcto (`fix:`/`feature:`/`chore:`) según `CLAUDE.md`, y crear/pushear el tag correspondiente no es parte de este plan | Bajo; es una decisión operativa al abrir la PR | Fuera de alcance de este plan.md — corresponde a quien abra la PR, no a una tarea de `@agent` |
| R-03 | Si en el futuro se añade una skill que sí compare funcionalmente con `grill-me` (que sigue existiendo como concepto/funcionalidad, solo retirada del perfil `default`), habrá que revisar de nuevo `ai-toolkit/default/README.md` | Bajo, futuro | No accionable ahora; el requirements confirma que `grill-me` no se elimina globalmente, solo del perfil `default` |

### Critical Files for Implementation
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\catalog.yaml
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\ai-toolkit\default\commands\grill-me.md
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\.claude\commands\grill-me.md
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\ai-toolkit\default\commands\specify-feature.md
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\.claude\commands\specify-feature.md
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\README.md
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\CHANGELOG.md
