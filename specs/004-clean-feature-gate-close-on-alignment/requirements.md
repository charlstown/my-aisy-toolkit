# clean-feature debe cerrar el issue solo si el plan está completo y product-spec/tech-spec quedaron alineados
Feature Branch: 004-clean-feature-gate-close-on-alignment

Created: 2026-08-02

Status: Draft

Input: User description: "todos los issues abiertos"

## User Scenarios & Testing (mandatory)

### User Story 1 - Cierre condicional del issue según alineación de specs en Step 6.5 (Priority: P1)

Como usuario que ejecuta `clean-feature` sobre una o varias carpetas de feature/fix, quiero que el issue asociado a cada carpeta se cierre en Step 6.5 solo cuando su `plan.md` esté completo Y `product-spec.md`/`tech-spec.md` hayan quedado alineados (ya sea porque el audit de Step 3 los encontró `ALIGNED` desde el inicio, o porque Step 4 los actualizó correctamente sin errores). Si Step 4 falla al actualizar `product-spec.md` o `tech-spec.md`, el issue de esa carpeta no debe cerrarse y el resumen final (Step 8) debe dejar constancia de qué carpeta quedó con specs pendientes de alinear.

Why this priority: Es el único comportamiento pedido por el issue #14; hoy `clean-feature` cierra issues sin verificar el resultado del audit/actualización de specs, lo que puede cerrar issues cuyo `product-spec`/`tech-spec` quedaron desalineados con los cambios reales.

Independent Test: Ejecutar `clean-feature` sobre carpetas de prueba que cubran los tres casos (alineado, falla de actualización, no aplica) y verificar que el cierre de cada issue y el contenido del resumen final se comporten según lo descrito en cada Acceptance Scenario.

Acceptance Scenarios:

1. Given una carpeta con `plan.md` completo (sin `- [ ]` pendientes) y `product-spec.md`/`tech-spec.md` que el Step 3 encontró `ALIGNED` o que el Step 4 actualizó correctamente sin errores, When `clean-feature` llega a Step 6.5 para esa carpeta, Then el issue asociado se cierra normalmente como hoy, con comentario y resumen de cambios.
2. Given una carpeta con `plan.md` completo pero cuya actualización de `product-spec.md` o `tech-spec.md` en Step 4 falla (el subagente de edición reporta error o el spec queda sin actualizar), When `clean-feature` llega a Step 6.5 para esa carpeta, Then el issue asociado NO se cierra, y el resumen final (Step 8) indica claramente que esa carpeta quedó con specs pendientes de alinear.
3. Given una carpeta con `plan.md` completo donde `product-spec.md` y/o `tech-spec.md` no aplican al plan (no requerían auditoría según la tabla de Step 3, o el Step 3 los encontró `ALIGNED` desde el inicio sin cambios), When `clean-feature` llega a Step 6.5 para esa carpeta, Then el issue asociado se cierra igual, sin exigir alineación forzada donde no corresponde.

## Edge Cases

- Cuando hay varias carpetas seleccionadas en el mismo run, cada una se evalúa de forma independiente: un fallo de alineación de `product-spec`/`tech-spec` en una carpeta no bloquea el cierre del issue de las demás carpetas.
- El chequeo de alineación que condiciona el cierre se limita estrictamente a `product-spec.md` y `tech-spec.md`; el resultado de la auditoría/actualización de specs opcionales (`css-spec`, `ui-spec`, `infra-spec`, `security-spec`, `roadmap`) no debe influir en la decisión de cerrar o no el issue.

## Requirements (mandatory)

### Functional Requirements

- FR-001: `clean-feature` MUST verificar, antes de cerrar el issue en Step 6.5 para una carpeta dada, el resultado del audit de Step 3 y de la actualización de Step 4 específicamente para `product-spec.md` y `tech-spec.md`.
- FR-002: El chequeo MUST limitarse a `product-spec.md` y `tech-spec.md`; el resto de specs opcionales (`css-spec`, `ui-spec`, `infra-spec`, `security-spec`, `roadmap`) MUST NOT condicionar el cierre del issue.
- FR-003: Si `product-spec.md` y/o `tech-spec.md` no aplican al plan (no requerían auditoría según la tabla de Step 3) o el Step 3 los encontró `ALIGNED` desde el inicio sin cambios, MUST considerarse alineados por defecto y MUST NOT bloquear el cierre del issue.
- FR-004: Si el Step 3 detectó desalineación en `product-spec.md` y/o `tech-spec.md` y el Step 4 actualizó el spec correctamente sin errores, MUST considerarse alineado y MUST NOT bloquear el cierre del issue.
- FR-005: Si el Step 4 falla al aplicar la actualización a `product-spec.md` o `tech-spec.md` (el subagente de edición reporta error o el spec queda sin actualizar), el issue asociado a esa carpeta MUST NOT cerrarse en Step 6.5.
- FR-006: Cuando un issue no se cierra por fallo de alineación, el resumen final de Step 8 MUST dejar constancia clara de qué carpeta(s) quedaron con la alineación de `product-spec`/`tech-spec` pendiente.
- FR-007: El chequeo de alineación MUST evaluarse por carpeta de forma independiente cuando hay varias carpetas seleccionadas en el mismo run; un fallo de alineación en una carpeta MUST NOT bloquear el cierre del issue de las demás carpetas.
- FR-008: La plantilla MUST quedar actualizada en `ai-toolkit/default/commands/clean-feature.md` y sincronizada en `.claude/commands/clean-feature.md`; el mecanismo de sincronización a futuro entre ambas copias es `setup-ai`.
- FR-009: El resultado de los Steps 3 y 4 para `product-spec.md`/`tech-spec.md` MUST exponerse como una variable de estado explícita por spec, con uno de estos valores: no aplica, aplica y `ALIGNED`, aplica y actualizado correctamente, o aplica y falló la actualización.
- FR-010: Cuando una carpeta queda con specs pendientes de alinear, el resumen final de Step 8 MUST indicar tanto la carpeta como qué spec concreto (`product-spec` y/o `tech-spec`) falló su actualización.

### Key Entities (include if feature involves data)

- Carpeta de feature/fix: unidad procesada por `clean-feature` en cada iteración; contiene `plan.md` y opcionalmente otros artefactos; tiene un issue de GitHub asociado.
- Resultado de audit de Step 3: estado de alineación de `product-spec.md`/`tech-spec.md` respecto a los cambios de la carpeta (aplica y está `ALIGNED`, aplica y está desalineado, o no aplica según la tabla de Step 3).
- Resultado de actualización de Step 4: resultado de aplicar la corrección a `product-spec.md`/`tech-spec.md` cuando el Step 3 detectó desalineación (éxito sin errores, o fallo).
- Issue de GitHub: recurso externo que se cierra o se deja abierto en Step 6.5 según el resultado combinado de plan completo + alineación de `product-spec`/`tech-spec`.
- Resumen final (Step 8): reporte de cierre del run de `clean-feature` que debe listar las carpetas cuyo issue no se cerró por specs pendientes de alinear.

## Success Criteria (mandatory)

### Measurable Outcomes

- SC-001: El 100% de las carpetas procesadas por `clean-feature` con `plan.md` completo y `product-spec`/`tech-spec` `ALIGNED` o actualizados sin errores terminan con su issue asociado cerrado, con comentario y resumen de cambios, igual que el comportamiento actual.
- SC-002: El 100% de las carpetas procesadas con `plan.md` completo donde el Step 4 falla actualizando `product-spec.md` o `tech-spec.md` terminan con su issue asociado abierto y listado explícitamente en el resumen final (Step 8) como pendiente de alineación.
- SC-003: El 0% de las carpetas donde `product-spec`/`tech-spec` no aplican al plan (fuera de la tabla de Step 3, o `ALIGNED` desde el inicio) quedan bloqueadas indebidamente para el cierre de su issue.

## Assumptions

- Se asume que los Steps 3 (audit) y 4 (actualización) de `clean-feature` ya producen, o pueden producir, un resultado distinguible por spec (aplica/no aplica, alineado/desalineado, actualización exitosa/fallida) que Step 6.5 puede consultar para tomar la decisión de cierre; el issue no detalla el mecanismo interno exacto de esta señal.
