# Plan — Step 6 de setup-ai debe incluir siempre el agente confirmado en Step 1

Feature Branch: `fix/setup-ai-step-6-global-launcher-offer`

Requirements: `specs/fix-setup-ai-step-6-global-launcher-offer/requirements.md`

Created: 2026-08-02

## 1. Contexto encontrado (verificado en el repo)

| Hallazgo | Evidencia |
|---|---|
| `setup-ai.md` solo existe en la raíz del repo — no hay copia sincronizada como en otras skills (`ai-toolkit/default/commands/` o `.claude/commands/`) | `find . -iname "setup-ai*"` solo devuelve `./setup-ai.md` |
| Step 1 pregunta el agente objetivo palabra por palabra y nunca lo infiere de carpetas existentes (ADR-004, FR-004) | `setup-ai.md` L61-93 |
| Step 6 corre su propia detección de candidatos, totalmente desacoplada de la respuesta de Step 1: comprueba si `~/.claude/` existe (Claude Code) y si `~/.codex/` o `~/.agents/` existe (Codex CLI); "An agent only becomes a candidate for this step if its user-level directory exists" | `setup-ai.md` L233-240 |
| El texto ya deja explícito que esta detección "never replaces... the mandatory question in Step 1" — es decir, ya se reconoce que Step 1 y Step 6 son fuentes independientes, pero no hay ningún mecanismo que reutilice la respuesta de Step 1 dentro de Step 6 | `setup-ai.md` L237-240 |
| El descarte por fichero-ya-existente (`~/.claude/commands/setup-ai.md`, `~/.codex/skills/setup-ai/SKILL.md` o el fallback `~/.agents/...`) solo pide "make a note — you'll report it in the Wrap up" — no exige decirlo en el momento | `setup-ai.md` L242-247 |
| Si no queda ningún candidato tras la detección y el chequeo de fichero existente, la instrucción es "skip straight to the Wrap up — do not ask anything", sin exigir ninguna explicación en ese punto | `setup-ai.md` L249-251 |
| El prompt literal de la oferta ya contempla "keeping only the lines for the agents you'd actually write for (drop the other agent's line entirely if it isn't a candidate...)" — el mecanismo de selección de líneas ya existe, el problema es qué entra en la lista de candidatos antes de llegar a ese prompt | `setup-ai.md` L253-271 |
| El Wrap-up tiene una sección `Global launcher` con 4 categorías ya definidas: Written / Already existed / User declined / Write failed — no existe una categoría para "candidato descartado porque su directorio de usuario genuinamente no existe" | `setup-ai.md` L406-435 |
| El propio `Environment` del requirements documenta que el caso reportado ocurrió en una sesión de Claude Code **despachada desde el móvil** (OS: iOS) — un entorno efímero donde `~/.claude/` puede genuinamente no existir aunque la sesión completa esté corriendo como Claude Code. Esto confirma que el chequeo de existencia de directorio no es un bug en sí mismo (puede ser una situación real), sino que el bug es la falta de transparencia cuando ese chequeo excluye al agente confirmado | Requirements, sección `## Environment` |
| `specs/product-spec.md` (L59) y `specs/tech-spec.md` (L74) describen el comportamiento actual de Step 6 como "only for agents already present on the machine" / "the agent's user-level directory actually exists" — quedarán desactualizados tras este fix, pero su realineación corresponde a `/clean-feature`, no a este plan | `specs/product-spec.md` L59; `specs/tech-spec.md` L74 |

**Conclusión de alcance:** el único fichero de código/instrucciones a modificar es `setup-ai.md`, exclusivamente dentro de Step 6 (L227-388) y la sección `Global launcher` del Wrap-up (L406-435). Step 1 (L61-93) se lee mediante `git diff` en verificación para confirmar que no se toca. `specs/product-spec.md` y `specs/tech-spec.md` quedan fuera de alcance de este plan (los recogerá `/clean-feature`).

## 2. Decisiones

### D-01 — Step 6 reutiliza la respuesta de Step 1 como agente "confirmado"; la detección por directorio se mantiene, pero deja de ser una exclusión silenciosa

**Decisión:** Step 6 recuerda explícitamente cuál fue la respuesta de Step 1 (`confirmed_agent`: Claude Code o Codex CLI) y lo trata como un candidato de partida. La detección por existencia de `~/.claude/`, `~/.codex/` o `~/.agents/` (L233-240) **se mantiene sin cambios** como mecanismo para decidir si el *otro* agente (el no confirmado) entra también como candidato adicional — eso ya funciona hoy y no es el bug.
**Por qué:** el requirements documenta un caso real (sesión iOS/móvil) donde el directorio de usuario del agente confirmado puede genuinamente no existir; eliminar el chequeo por completo para el agente confirmado iría más allá de lo que pide el AC-03 ("its user-level directory genuinely doesn't exist" se documenta ahí como razón legítima de descarte). Lo que cambia no es *si* se comprueba, sino *qué pasa cuando el resultado excluye al agente confirmado*.
**Alternativa descartada:** ignorar por completo el resultado del probe de directorio para el agente confirmado y ofrecerlo siempre incondicionalmente. Se descarta porque contradice AC-03, que explícitamente permite el descarte por directorio ausente como caso legítimo — solo exige que se explique.

### D-02 — Único cambio de comportamiento real: toda exclusión del agente confirmado debe anunciarse en el propio turno de Step 6, no solo en el Wrap-up

**Decisión:** cuando el agente confirmado en Step 1 queda fuera de la lista final de candidatos de Step 6 —ya sea porque (a) su fichero de launcher ya existe en destino, o (b) su directorio de usuario genuinamente no existe—, Step 6 debe decirlo explícitamente como parte de su propio mensaje al usuario, en el mismo turno en que se muestra (o se omite) la oferta. Esto aplica tanto si sobrevive otro candidato (el "otro" agente) como si no sobrevive ninguno.
**Por qué:** es exactamente lo que pide AC-03 ("the user is told why in the moment — not left to infer it or discover it only in the Wrap-up note") y resuelve directamente el bug reportado (el usuario tuvo que escribir una corrección manual porque nada en el momento explicaba la ausencia de Claude Code).
**Cubre también AC-02:** al forzar que cualquier exclusión del agente confirmado se anuncie en el momento, se elimina por construcción el escenario "se ofrece solo el otro agente sin nombrar ni explicar el confirmado".

### D-03 — El Wrap-up gana una quinta categoría en `Global launcher`, sin tocar las 4 existentes

**Decisión:** se añade una nueva viñeta a la sección `Global launcher` del Wrap-up (junto a Written / Already existed / User declined / Write failed) para el caso "el agente confirmado en Step 1 no fue ofrecido porque su directorio de usuario no existe" — como refuerzo/registro adicional, no como sustituto del anuncio en el momento (D-02). Las 4 categorías existentes no se modifican.
**Por qué:** el Wrap-up ya es "the log" de todo lo que pasó con el launcher (L390-393); dejar sin categoría el nuevo motivo de exclusión sería la misma clase de gap documental que ya cubre bien para los otros 4 casos.

### D-04 — El prompt literal de la oferta (L258-271) no cambia su forma, solo qué líneas puede incluir

**Decisión:** el mecanismo ya documentado de "keeping only the lines for the agents you'd actually write for" (L253-256) se mantiene tal cual. Lo que cambia es el conjunto de candidatos que llega a ese punto (D-01), y que, si el agente confirmado no llega, debe ir acompañado de la frase explicativa de D-02 **antes o junto** al prompt (o en su lugar, si no queda ningún candidato — ver D-05).
**Alternativa descartada:** reescribir el prompt literal en sí (el bloque fenced de L258-271) para incluir condicionalmente una nota — se descarta a favor de una frase separada, previa al prompt, para no complicar el bloque "ask this once, word for word" que debe seguir siendo copiable tal cual.

### D-05 — El caso "no queda ningún candidato" (L249-251) también necesita explicación en el momento cuando la razón es la exclusión del agente confirmado

**Decisión:** si tras aplicar D-01 no queda ningún candidato (ni el confirmado, por fichero-existente o directorio-ausente, ni el otro agente detectado), Step 6 sigue sin hacer la pregunta yes/no (eso no cambia), pero debe emitir una frase corta explicando por qué no hay oferta, en vez de pasar en silencio al Wrap-up. Esto es distinto de "skip straight to the Wrap up — do not ask anything": la instrucción de no preguntar se mantiene, pero se añade la obligación de explicar brevemente el motivo antes de continuar.
**Por qué:** es la lectura literal de AC-03 aplicada al caso límite donde ni siquiera hay pregunta que mostrar — "no dejar al usuario inferirlo" aplica igual de fuerte cuando no hay oferta en absoluto.

### D-06 — Fuera de alcance: `specs/product-spec.md` y `specs/tech-spec.md`

**Decisión:** no se tocan en este plan, aunque quedarán desactualizados en su descripción de Step 6 (ver hallazgo en tabla anterior).
**Por qué:** el requirements no los lista como ficheros a modificar, y el repo tiene un mecanismo dedicado (`/clean-feature`) para alinear specs raíz después de cerrar una feature — igual que en `002-remove-grill-me-from-default-profile` se decidió explícitamente qué ficheros entraban y cuáles no (D-02 de ese plan). Forzarlo aquí ampliaría el alcance sin necesidad.

## 3. Plan por batches

### Batch 0 — Bloquear la redacción exacta del cambio

- [x] @architect · Bloquear el texto literal a insertar/modificar en `setup-ai.md` Step 6 y Wrap-up, a partir de las decisiones D-01 a D-05: (a) la frase que Step 6 debe usar para recordar y nombrar explícitamente `confirmed_agent` (la respuesta de Step 1), dejando claro que la detección por directorio de L233-240 sigue aplicando sin cambios para decidir candidatos adicionales; (b) la frase explicativa exacta que se debe decir en el momento cuando el agente confirmado queda excluido por fichero-ya-existente (extensión de L242-247, que hoy solo dice "make a note... report in Wrap up"); (c) la frase explicativa exacta para cuando el agente confirmado queda excluido porque su directorio de usuario genuinamente no existe (caso nuevo, no cubierto hoy en ningún punto de Step 6); (d) el ajuste mínimo a L249-251 para que el camino "no queda ningún candidato" incluya una frase breve explicando el motivo antes de pasar al Wrap-up, sin convertirlo en una pregunta; (e) el punto exacto de inserción de estas frases relativo al bloque fenced del prompt "word for word" (L258-271), que no se reescribe; (f) el texto de la quinta viñeta nueva en la sección `Global launcher` del Wrap-up (junto a Written/Already existed/User declined/Write failed, L406-435) para el caso "confirmado, no ofrecido por directorio ausente". Entregar todo como bloque literal listo para copiar/pegar en Batch 1, dejando explícito que Step 1 (L61-93), el bloque fenced del prompt de L258-271 y las 4 categorías existentes del Wrap-up no se reescriben, solo se les añade contenido nuevo alrededor.

### Batch 1 — Aplicar el cambio en `setup-ai.md`

- [x] @code-developer · Editar `setup-ai.md` Step 6 (L227-388): aplicar literalmente el texto bloqueado en Batch 0 para (1) introducir y nombrar `confirmed_agent` reutilizando la respuesta de Step 1 sin modificar el mecanismo de detección por directorio de L233-240; (2) extender la regla de descarte por fichero-ya-existente (L242-247) para que, cuando el descartado sea el agente confirmado, se anuncie explícitamente en el mismo turno, no solo como nota para el Wrap-up; (3) añadir el caso nuevo — agente confirmado descartado porque su directorio de usuario genuinamente no existe — con su propio anuncio explícito en el momento; (4) ajustar el camino "no queda ningún candidato" (L249-251) para incluir la frase breve explicativa antes de pasar al Wrap-up, sin convertirlo en pregunta. No modificar el bloque fenced del prompt "ask this once, word for word" (L258-271) más allá de qué líneas se seleccionan, ni las secciones "For Claude Code, write to..." / "For Codex CLI, write to..." (L281-388), que quedan igual. Confirmar visualmente que Step 1 (L61-93) permanece byte-idéntico.
- [x] @code-developer · Editar `setup-ai.md` Wrap-up, sección `Global launcher` (L406-435): añadir la quinta viñeta bloqueada en Batch 0 para el caso "agente confirmado no ofrecido porque su directorio de usuario no existe", sin modificar el texto de las 4 categorías existentes (Written / Already existed / User declined / Write failed) ni el ejemplo final de L437-454.

### Batch 2 — Verificación

- [x] @tester · Verificar los tres criterios de aceptación por trazado del texto (no hay runtime ejecutable para un fichero de instrucciones): **(AC-01)** con `confirmed_agent = Claude Code`, trazar el caso donde `~/.claude/` existe y su fichero de launcher no existe aún, y `~/.codex/` también existe — confirmar que las instrucciones resultantes producen una oferta que incluye la línea de Claude Code, sin importar el resultado de la detección de Codex. **(AC-02)** trazar el caso donde `~/.claude/` no es detectado (directorio ausente) pero `~/.codex/` sí lo es — confirmar que las instrucciones ya no permiten una oferta que nombre solo Codex sin explicar antes o junto a ella por qué Claude Code no aparece; confirmar también el caso donde el fichero de Claude Code ya existe en destino (mismo resultado: no se ofrece solo Codex en silencio). **(AC-03)** confirmar en ambos casos de exclusión del agente confirmado (fichero ya existe / directorio ausente) que el texto exige una frase explicativa en el propio turno de Step 6, y por separado confirmar que la quinta viñeta nueva del Wrap-up cubre el caso de directorio ausente. Reportar cualquier ambigüedad de redacción que permita a un agente ejecutor omitir la explicación en el momento, devolviendo a Batch 1 si se encuentra alguna (no corregir el fichero directamente).
- [x] @tester · Verificar que Step 1 no fue tocado ni debilitado: correr `git diff` sobre `setup-ai.md` y confirmar que las líneas 61-93 (Step 1 completo) no aparecen en el diff. Confirmar además que el bloque fenced del prompt "ask this once, word for word" (L258-271 en la versión original) sigue siendo un bloque copiable palabra por palabra, y que las secciones de escritura efectiva ("For Claude Code, write to...", "For Codex CLI, write to...") no cambiaron. Reportar cualquier discrepancia con ruta y línea exacta.
- [x] @tester · Verificar el caso límite "no queda ningún candidato": trazar el escenario donde el agente confirmado es excluido (por cualquiera de las dos razones legítimas) y el otro agente tampoco es detectado — confirmar que las instrucciones resultantes siguen sin formular la pregunta yes/no, pero ahora incluyen la frase explicativa breve antes de pasar al Wrap-up, en vez de un salto silencioso.

### Batch 3 — Quality gate

- [ ] @judge · Revisar el diff completo de `setup-ai.md` contra `specs/fix-setup-ai-step-6-global-launcher-offer/requirements.md`: confirmar AC-01 (el agente confirmado en Step 1 siempre es candidato en la oferta de Step 6, salvo exclusión legítima), AC-02 (nunca se ofrece solo el otro agente sin nombrar/explicar el confirmado, salvo que su fichero ya exista), AC-03 (toda exclusión del confirmado se explica en el momento, no solo en el Wrap-up). Confirmar que Step 1 (L61-93) no fue modificado, que el bloque fenced del prompt de la oferta sigue siendo palabra por palabra, y que las 4 categorías existentes del Wrap-up `Global launcher` no cambiaron de texto (solo se añadió la quinta). Confirmar que no se tocó `specs/product-spec.md` ni `specs/tech-spec.md` (D-06, fuera de alcance). Emitir PASS o CHANGES_REQUESTED con fichero y línea exacta para cada hallazgo; si CHANGES_REQUESTED, devolver a @code-developer (Batch 1).

## 4. Dependencias entre batches

```
Batch 0 (redacción exacta bloqueada)
        │
        ▼
Batch 1 (aplicar cambio en setup-ai.md: Step 6 + Wrap-up)
        │
        ▼
Batch 2 (verificación: AC-01/02/03, Step 1 intacto, caso "sin candidatos")
        │
        ▼
Batch 3 (quality gate)
```

Las dos tareas del Batch 1 tocan el mismo fichero en secciones distintas (Step 6 vs. Wrap-up) — se recomienda ejecutarlas en secuencia, no en paralelo, para evitar conflictos de edición sobre el mismo fichero. Las tres tareas del Batch 2 son independientes entre sí.

## 5. Riesgos y consideraciones fuera de alcance

| # | Riesgo / consideración | Impacto | Mitigación / estado |
|---|---|---|---|
| R-01 | `specs/product-spec.md` (L59) y `specs/tech-spec.md` (L74, L149-152) quedarán describiendo el comportamiento antiguo de Step 6 | Bajo, documental | Fuera de alcance de este plan (D-06); corresponde a `/clean-feature` tras cerrar esta feature |
| R-02 | El caso real reportado ocurrió en una sesión iOS/móvil donde el propio entorno del agente confirmado puede ser efímero — no hay forma de verificar en CI un entorno real de Codex ni de Claude Code sin tocar el `HOME` real, tal como ya advierte `specs/tech-spec.md` L151-152 | Medio; ya es una limitación conocida y documentada del repo | La verificación de este plan (Batch 2) es por trazado de texto, no por ejecución real — igual que otras features de instrucciones en este repo (ver `002`/`005`) |
| R-03 | El título de la PR que cierre esta feature debe llevar el prefijo `fix:` según la convención observada en el repo | Bajo | Fuera de alcance de este plan.md — decisión operativa al abrir la PR |

### Critical Files for Implementation

- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\setup-ai.md (único fichero a modificar — Step 6 completo, L227-388, y la sección `Global launcher` del Wrap-up, L406-435; Step 1, L61-93, se usa solo como referencia de solo-lectura para confirmar que no se toca)
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\specs\fix-setup-ai-step-6-global-launcher-offer\requirements.md (fuente de AC-01 a AC-03 que este plan implementa)
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\specs\product-spec.md (solo lectura — describe el comportamiento actual de Step 6 en L59; quedará desalineado tras el fix, pero fuera de alcance de este plan)
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\specs\tech-spec.md (solo lectura — describe el comportamiento actual de Step 6 en L74 y las advertencias de verificación en L149-152; igualmente fuera de alcance)
