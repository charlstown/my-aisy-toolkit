# Plan — Eliminar jerga interna (best-effort) del prompt de usuario en setup-ai

Feature Branch: `001-prompt-setup-ai-expone-best-effort-al-usuario`

Requirements: `specs/001-prompt-setup-ai-expone-best-effort-al-usuario/requirements.md`

Source Issue: https://github.com/charlstown/my-aisy-toolkit/issues/36

Created: 2026-08-04

## 1. Contexto encontrado (verificado en el repo)

| Hallazgo | Evidencia |
|---|---|
| `setup-ai.md` existe una sola vez en el repo, en la raíz. No hay copia sincronizada bajo `ai-toolkit/`, `.claude/commands/` ni ningún otro sitio | `find . -iname "setup-ai*"` devuelve únicamente `./setup-ai.md` |
| Las 4 ocurrencias de "best-effort" en `setup-ai.md` son exactamente las que documenta el requirements: L71, L307, L328 y L546. No hay ninguna más en el fichero | `grep -rn -i "best.effort" setup-ai.md` |
| **L71 es el único prompt literal de cara al usuario** con la jerga: vive dentro del bloque fenced L67-72 del Step 1, precedido por "**Target agent — always ask this, word for word.**" (L63) | `setup-ai.md` L61-72 |
| **L307 no es una mención autónoma: es una referencia cruzada** — "the create / overwrite / leave-alone rules below, and the best-effort caveat — applies to util files the same" apunta al párrafo de L328. Si se toca L328 sin tocar L307, la referencia queda huérfana | `setup-ai.md` L304-307 y L328 |
| **L328 no es solo una etiqueta: arrastra una regla de comportamiento real** — el párrafo `**A note on quality:**` termina con "do the best job you can, but don't claim it's an exact translation when you tell the user what happened", que gobierna lo que el agente reporta en el Wrap up | `setup-ai.md` L328-332 |
| **L546 está FUERA del bloque fenced del launcher global de Codex.** La valla ` ``` ` que cierra el contenido escrito byte-for-byte está en L543; L545-547 es prosa dirigida al agente | `setup-ai.md` L515-547 |
| Los dos bloques ` ```markdown ` de Step 6 (launcher de Claude Code desde L457 y launcher de Codex hasta L543) se escriben "exactly as it appears below — byte-for-byte, no reformatting" (FR-008). **No contienen ninguna ocurrencia de "best-effort"**, así que esta feature no los toca en absoluto | `setup-ai.md` L449-450 y grep sin resultados en L457-543 |
| El fichero está lleno de referencias internas agent-facing (`ADR-004`, `FR-010`, `D-07`, `U-01`, `SC-004`…) que el usuario nunca ve, y esas no forman parte del defecto reportado | `setup-ai.md` L65, L326, L359, L383, L401, L547 |
| Los ADRs no son ficheros propios: `ADR-002` y `ADR-007` viven dentro de `specs/tech-spec.md` (L214 y ss.). "Fuera de alcance ADR-002/ADR-007" equivale a "no tocar `specs/tech-spec.md`" | `grep -rn "ADR-002" specs/` |
| `specs/ui-spec.md` L41 y L99 también mencionan "best-effort", pero describen la **nota del README**, no el prompt del Step 1. SC-002 excluye explícitamente los READMEs, así que quedan fuera igual que el resto de docs internos | `specs/ui-spec.md` L38-41, L98-99 |
| **No existe ninguna verificación automatizada sobre el contenido de `setup-ai.md`**: los únicos workflows son `pr-title-check.yml` (valida el prefijo del título de PR) y `publish-version-tag.yml`. No hay linter de markdown, ni test del instalador, ni build | `ls .github/workflows/` |

**Conclusión de alcance:** un único fichero a modificar, `setup-ai.md`, en cuatro puntos (L71, L307, L328, L546). Nada más del repo entra en el diff: ni `specs/`, ni `README.md` / `README-ES.md`, ni `ai-toolkit/`, ni `catalog.yaml`.

## 2. Decisiones

### D-01 — L71: borrado quirúrgico, sin texto sustitutivo

**Decisión:** la línea 71 pasa de `  2. Codex CLI (best-effort support)` a `  2. Codex CLI`. Se elimina el paréntesis completo, no se sustituye por nada, y el resto del bloque fenced (L67-72) no se toca.
**Por qué:** es literalmente FR-001 + FR-002 y el AC-2 del requirements ("la opción queda simplemente como 'Codex CLI', sin añadir ningún texto sustitutivo").
**Alternativas descartadas:** (a) sustituir por `(experimental)` / `(soporte no verificado)` / `(beta)` — descartada porque FR-002 lo prohíbe explícitamente y porque cualquier etiqueta sigue siendo una advertencia sin información accionable para el usuario; (b) reescribir el prompt entero para que suene más natural — descartada por alcance: el prompt se pide "word for word" y todo cambio adicional obliga a revalidar un texto que hoy funciona.

### D-02 — L328: se elimina la etiqueta, se conserva la regla de comportamiento

**Decisión:** de `**A note on quality:** this translation is best-effort. You're producing your own live interpretation...` se borra únicamente la frase `this translation is best-effort.`. El párrafo arranca directamente en `You're producing your own live interpretation of the source content...` y **se mantiene íntegro el resto**, incluido el cierre "do the best job you can, but don't claim it's an exact translation when you tell the user what happened".
**Por qué:** FR-004 pide que el agente no repita la jerga si parafrasea el texto al usuario, no que desaparezca la instrucción. El cierre del párrafo es una regla de comportamiento activa sobre el Wrap up; borrarla cambiaría cómo el instalador reporta, que no es lo que pide este issue.
**Alternativas descartadas:** (a) borrar el párrafo entero — descartada porque elimina una regla de comportamiento no relacionada con el defecto (scope creep con riesgo de regresión); (b) reformular a "esta traducción es aproximada / no verificada" — descartada porque es el mismo concepto con otro nombre y la frase siguiente ("not applying a verified mapping... no guarantee it's a perfect equivalent") ya lo dice en lenguaje llano y con más precisión, así que la etiqueta es pura redundancia.
**Nota para quien implemente:** el texto conservado contiene la palabra "best" en "do the best job you can". No es el término prohibido y no debe tocarse: un `grep -i "best.effort"` no la captura.

### D-03 — L307: se ajusta la referencia cruzada para no dejarla huérfana

**Decisión:** en L307, `and the best-effort caveat` pasa a `and the quality caveat below`, apuntando al párrafo `**A note on quality:**` que D-02 conserva bajo ese mismo título.
**Por qué:** L307 es una referencia, no una definición. Tras D-02 ya no existe "el best-effort caveat" con ese nombre en el fichero, así que dejarlo intacto rompería la coherencia interna del documento además de dejar viva la jerga (SC-002 exige las tres menciones narrativas corregidas).
**Alternativa descartada:** borrar el inciso entero (`and the best-effort caveat`) — descartada porque la frase enumera qué reglas del Step 5 aplican también a los ficheros de `utils`; quitar un elemento de la enumeración cambia el alcance de esa regla.

### D-04 — L546: se conserva el hecho técnico y las referencias internas, se elimina solo la etiqueta

**Decisión:** `As with the rest of Codex support, this path is best-effort (ADR-002) — including the path itself, it hasn't been verified against a real Codex CLI installation (U-01).` pasa a `As with the rest of Codex support, this path hasn't been verified against a real Codex CLI installation (ADR-002, U-01).` Se preserva el dato verificable (la ruta no está verificada) y ambas referencias internas, fusionadas en un único paréntesis.
**Por qué:** el defecto es la etiqueta, no el aviso. La no-verificación de la ruta es información técnica real que el agente necesita (y que `specs/tech-spec.md` L299 documenta como U-01); eliminarla dejaría al agente sin contexto sobre por qué esa escritura puede resultar inerte.
**Alternativa descartada:** borrar la frase completa — descartada porque perdería el aviso de U-01, que no tiene nada que ver con el issue #36.

### D-05 — Las referencias internas tipo `ADR-xxx` / `FR-xxx` / `U-01` NO se limpian

**Decisión:** esta feature no toca ninguna referencia interna del fichero (`ADR-002`, `FR-008`, `D-07`, `U-01`, `SC-004`…), ni siquiera en las líneas que sí se editan.
**Por qué:** son agent-facing, están por todo el documento (más de una docena de sitios), y el issue #36 reporta un único término concreto filtrándose a un prompt de usuario. Ampliar a "auditar toda referencia interna" es una feature distinta; el propio requirements lo acota en sus Assumptions ("no incluye una auditoría general de todo el repositorio").

### D-06 — Documentación interna y READMEs: intactos (verificación explícita, no solo intención)

**Decisión:** `specs/tech-spec.md` (contiene ADR-002 y ADR-007), `specs/product-spec.md`, `specs/roadmap.md`, `specs/ui-spec.md`, `README.md`, `README-ES.md` y `ai-toolkit/default/README.md` conservan sus menciones a "best-effort" sin cambios. La verificación no es declarativa: se comprueba con `git diff --name-only`, que debe listar exactamente un fichero.
**Por qué:** FR-003 y SC-002. `ui-spec.md` y `ai-toolkit/default/README.md` no aparecen nominalmente en FR-003, pero sus menciones describen la nota del README (no el prompt del Step 1), y SC-002 excluye los READMEs explícitamente.

### D-07 — Sin tareas de test automatizado; verificación por grep + revisión

**Decisión:** el plan no incluye tareas de `@test-developer` ni de `@tester`. La verificación de SC-001 y SC-002 se hace con `grep` y `git diff` dentro de la tarea de revisión de `@judge`.
**Por qué:** verificado en el repo — no hay suite de tests, ni linter de markdown, ni build para `setup-ai.md`; los únicos workflows son `pr-title-check.yml` y `publish-version-tag.yml`. `setup-ai.md` es un fichero de instrucciones que interpreta un agente en runtime, no código ejecutable: montar aquí un test automatizado sería infraestructura nueva sin pedirla.

### D-08 — Anclar las ediciones por texto literal, nunca por número de línea

**Decisión:** las cuatro ediciones se aplican buscando la cadena exacta a sustituir, no posicionándose en la línea N.
**Por qué:** los números del requirements (71, 307, 328, 546) son válidos sobre el `main` actual (verificado uno a uno), pero D-02 y D-04 acortan párrafos y pueden reflowear líneas; si las tareas se ejecutan en secuencia, los números posteriores dejan de ser fiables. Las cuatro cadenas son únicas en el fichero.

## Batch 1 - Fix del prompt principal

- [x] @code-developer · Eliminar "(best-effort support)" del prompt del Step 1: en `setup-ai.md`, dentro del bloque fenced del Step 1 (L67-72, el que va precedido de "**Target agent — always ask this, word for word.**"), sustituir la línea exacta `  2. Codex CLI (best-effort support)` por `  2. Codex CLI`, respetando los dos espacios de indentación iniciales. No añadir ningún texto sustitutivo, advertencia, nota ni paréntesis alternativo (FR-002 lo prohíbe). No tocar la línea 1 del prompt (`  1. Claude Code`), ni la frase de apertura del bloque, ni el bloque de re-pregunta de L76-78, ni las preguntas de perfil y utils que vienen después. El diff de esta tarea debe ser exactamente una línea modificada en un único fichero.

## Batch 2 - Revisión de menciones narrativas

- [ ] @code-developer · Reescribir el párrafo `**A note on quality:**` del Step 5 (aprox. L328): localizar la cadena literal `**A note on quality:** this translation is best-effort. You're producing your own live` y eliminar únicamente la frase `this translation is best-effort. `, de forma que el párrafo pase a empezar por `**A note on quality:** You're producing your own live interpretation of the source content...`. Conservar sin ningún cambio el resto del párrafo hasta su final, incluidas las frases "not applying a verified mapping", "This is a documented, known limitation of Codex support (see Edge Cases and Known Limitations)" y el cierre "do the best job you can, but don't claim it's an exact translation when you tell the user what happened" — esa última frase es una regla de comportamiento del Wrap up y debe sobrevivir intacta (D-02). Ojo: "do the best job you can" contiene la palabra "best" pero NO es el término a eliminar; no tocarla. Reflowear el párrafo si el borrado deja una primera línea corta es aceptable, pero no reescribir ninguna otra palabra.
- [ ] @code-developer · Arreglar la referencia cruzada de la sección de utils del Step 5 (aprox. L304-307): en la frase `Everything else in this step — the translation you do yourself, the create / overwrite / leave-alone rules below, and the best-effort caveat — applies to util files the same.`, sustituir `and the best-effort caveat` por `and the quality caveat below`, de modo que siga apuntando al párrafo `**A note on quality:**` que la tarea anterior conserva bajo ese título. Mantener la enumeración completa (los tres elementos siguen ahí) y no alterar el resto de la frase ni los bloques de rutas de traducción de L290-302. Ejecutar esta tarea después de la anterior para que la referencia y su destino queden coherentes en el mismo estado del fichero.
- [ ] @code-developer · Reescribir la nota de la ruta del launcher de Codex (aprox. L545-547): sustituir la frase `As with the rest of Codex support, this path is best-effort (ADR-002) — including the path itself, it hasn't been verified against a real Codex CLI installation (U-01).` por `As with the rest of Codex support, this path hasn't been verified against a real Codex CLI installation (ADR-002, U-01).` Se conservan ambas referencias internas fusionadas en un paréntesis (D-04, D-05). **Crítico:** esta frase está FUERA del bloque fenced que se escribe byte-for-byte en el disco del usuario — la valla de cierre de ese bloque está en L543, verificado. No tocar absolutamente nada entre el ` ```markdown ` de apertura del launcher de Codex y su ` ``` ` de cierre, ni el bloque equivalente del launcher de Claude Code (a partir de L457): su contenido se escribe "exactly as it appears below — byte-for-byte" (FR-008) y ninguno de los dos contiene el término a eliminar. Tampoco tocar la frase siguiente sobre fallos de escritura (L549-552).

## Batch 3 - Revisión final

- [ ] @judge · Revisar el diff completo contra el requirements y verificar los criterios de éxito con comandos, no por lectura: (1) ejecutar `grep -rn -i "best.effort" setup-ai.md` y confirmar **0 resultados** (SC-001 + SC-002); (2) ejecutar `git diff --name-only` y confirmar que lista **exactamente un fichero**, `setup-ai.md` — cualquier aparición de `specs/tech-spec.md`, `specs/product-spec.md`, `specs/roadmap.md`, `specs/ui-spec.md`, `README.md`, `README-ES.md` o `ai-toolkit/default/README.md` es un fallo directo de FR-003/SC-002 y del requisito de no tocar ADR-002/ADR-007 (que viven dentro de `tech-spec.md`); (3) ejecutar `grep -rn -i "best.effort" specs/ README.md README-ES.md ai-toolkit/` y confirmar que esas menciones siguen presentes e intactas (deben seguir ahí: FR-003); (4) confirmar en el diff que la opción 2 del Step 1 quedó como `  2. Codex CLI` sin texto sustitutivo de ningún tipo (FR-002 / AC-2); (5) confirmar que el párrafo `**A note on quality:**` conserva su frase final sobre no afirmar una traducción exacta, y que la referencia cruzada de utils apunta a un caveat que sigue existiendo con ese nombre; (6) confirmar que ninguna línea dentro de los dos bloques fenced ` ```markdown ` del Step 6 (contenido del launcher global, escrito byte-for-byte, FR-008) aparece en el diff. Emitir PASS o CHANGES_REQUESTED indicando fichero y línea exacta de cada hallazgo; si es CHANGES_REQUESTED, devolver la tarea concreta a @code-developer en su batch de origen.

## Dependencias entre batches

```
Batch 1 (L71 — prompt de Step 1)
        │
        ▼
Batch 2 (menciones narrativas: A note on quality → referencia de utils → nota de ruta Codex)
        │
        ▼
Batch 3 (quality gate: grep + git diff)
```

- Batch 1 y Batch 2 tocan secciones distintas del mismo fichero, así que técnicamente son independientes, pero **las cuatro ediciones deben ejecutarse en secuencia, nunca en paralelo**: son todas sobre `setup-ai.md` y ediciones concurrentes sobre el mismo fichero se pisan.
- Dentro del Batch 2 el orden sí importa: primero el párrafo `**A note on quality:**`, después la referencia cruzada que lo nombra. Al revés, la referencia apuntaría durante un rato a un caveat con nombre distinto.
- Batch 3 depende de que las cuatro ediciones estén aplicadas: sus greps solo tienen sentido sobre el estado final.

## Riesgos y consideraciones fuera de alcance

| # | Riesgo / consideración | Impacto | Mitigación / estado |
|---|---|---|---|
| R-01 | Los números de línea del requirements (71, 307, 328, 546) dejan de ser fiables en cuanto una edición reflowea un párrafo | Medio — una edición podría aplicarse en el sitio equivocado | D-08: todas las tareas anclan por cadena literal única, y los números se dan como "aprox." |
| R-02 | Editar por error dentro de los bloques ` ```markdown ` del Step 6 cambiaría el contenido que se escribe byte-for-byte en el `~/` del usuario (FR-008) | Alto si ocurre | Verificado que la valla de cierre está en L543 y que L546 está fuera; la tarea correspondiente lo marca como crítico y el @judge lo comprueba en el punto (6) |
| R-03 | Al quitar la advertencia del prompt, un usuario de Codex CLI ya no recibe ninguna señal en el Step 1 sobre el nivel de soporte | Aceptado por diseño | Decisión explícita del requirements (FR-002, Edge Cases): "se asume que el soporte funcionará sin necesidad de comunicar matices en este prompt". El aviso sigue existiendo en README y specs |
| R-04 | Sin verificación automatizada, la única red de seguridad es el grep del Batch 3 | Bajo | D-07: no hay suite ni linter en el repo (verificado); el gate del @judge es ejecutable y determinista, no una lectura subjetiva |
| R-05 | La PR que cierre esta feature debe titularse con prefijo `fix:` según `CLAUDE.md` y el workflow `pr-title-check.yml`, y no puede hacerse push directo a `main` | Bajo | Fuera del alcance de este plan.md — decisión operativa al abrir la PR |
| R-06 | `specs/ui-spec.md`, `README.md`, `README-ES.md` y `ai-toolkit/default/README.md` mantienen la etiqueta "best-effort" de cara al lector del repo | Ninguno para esta feature | Fuera de alcance por SC-002 (excluye READMEs) y D-06. Si se quisiera homogeneizar el lenguaje de cara al usuario en el README, sería una feature aparte |

### Critical Files for Implementation

- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\setup-ai.md (**único fichero a modificar**: prompt del Step 1 en el bloque fenced L67-72; sección de utils del Step 5 en L304-307; párrafo `**A note on quality:**` en L328-332; nota de la ruta del launcher de Codex en L545-547. Los bloques ` ```markdown ` del Step 6 —launcher de Claude Code desde L457 y launcher de Codex hasta L543— son zona intocable: se escriben byte-for-byte)
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\specs\001-prompt-setup-ai-expone-best-effort-al-usuario\requirements.md (fuente de FR-001 a FR-004 y SC-001/SC-002 que este plan implementa)
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\specs\tech-spec.md (solo lectura — contiene ADR-002 (L214) y la limitación U-01 (L299); NO se modifica, FR-003)
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\specs\product-spec.md (solo lectura — sus menciones a "best-effort" se mantienen, FR-003)
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\specs\roadmap.md (solo lectura — sus menciones a "best-effort" se mantienen, FR-003)
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\specs\ui-spec.md (solo lectura — L41 y L99 describen la nota del README, no el prompt del Step 1; fuera de alcance por SC-002)
