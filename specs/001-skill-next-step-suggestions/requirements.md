# Sugerencias del siguiente paso al finalizar un skill
Feature Branch: 001-skill-next-step-suggestions

Created: 2026-08-01

Status: Draft

Input: User description: "#1"

## User Scenarios & Testing (mandatory)

### User Story 1 - Sugerencia visual del siguiente skill tras un flujo secuencial (Priority: P1)

Como usuario que ejecuta un skill perteneciente al flujo secuencial principal (`constitution` → `product-spec` → `tech-spec` → `roadmap` → `specify-feature` → `clarify-feature` → `plan-feature` → `implement-feature` → `clean-feature`), quiero que al terminar con éxito se muestre un bloque visual y de tono directo sugiriendo qué skill(s) ejecutar a continuación, para no tener que adivinar cuál es el siguiente paso.

Why this priority: es el comportamiento central pedido en la issue; sin esto no hay feature.

Independent Test: se puede probar ejecutando cualquier skill del flujo secuencial (p.ej. `product-spec`) hasta que finalice con éxito y verificando que el mensaje de cierre incluye el bloque destacado con la sugerencia del siguiente paso, entregando valor por sí solo (el usuario sabe qué hacer después sin consultar documentación).

Acceptance Scenarios:

1. Given un usuario ha ejecutado `product-spec` y este ha finalizado con éxito, When el skill cierra su ejecución, Then se muestra un bloque destacado tipo "✅ Listo. Siguiente paso sugerido:" con una lista corta (1-3 opciones) de skills a continuación, cada una con un emoji.
2. Given un usuario ha ejecutado cualquiera de los 9 skills del flujo secuencial (`constitution`, `product-spec`, `tech-spec`, `roadmap`, `specify-feature`, `clarify-feature`, `plan-feature`, `implement-feature`, `clean-feature`) y este finaliza con éxito, When se muestra el mensaje de cierre, Then su tono es directo, sin jerga y ligero, consistente con el principio "Keep it AIsy" descrito en `specs/product-spec.md`.

### User Story 2 - Exclusión de skills sin secuencia fija (Priority: P2)

Como usuario que ejecuta un skill que no pertenece al flujo secuencial (`new-issue`, `grill-me`), quiero que este NO muestre el bloque de sugerencia de siguiente paso, para no recibir sugerencias que no tienen sentido fuera de una secuencia fija.

Why this priority: es un criterio de aceptación explícito de la issue, pero de menor impacto que el comportamiento positivo de la User Story 1 (es una exclusión, no una capacidad nueva).

Independent Test: se puede probar ejecutando `new-issue` o `grill-me` hasta que finalicen y verificando que ninguno de los dos muestra el bloque de sugerencia de siguiente paso.

Acceptance Scenarios:

1. Given un usuario ha ejecutado `new-issue` o `grill-me`, When el skill finaliza su ejecución (con éxito o no), Then no se muestra ningún bloque de sugerencia de siguiente paso.

## Edge Cases

- Si un skill del flujo secuencial finaliza sin éxito (error, cancelación o resultado parcial), no se muestra ningún bloque de sugerencia de siguiente paso (ver FR-007).
- `clean-feature`, al ser el último skill de la secuencia principal, no muestra ningún bloque de sugerencia al finalizar (ver FR-006).
- Cuando el siguiente paso natural incluye un skill opcional/saltable (`roadmap` tras `tech-spec`, `clarify-feature` tras `specify-feature`), el bloque ofrece ambas alternativas (el paso opcional y el paso siguiente a él) como opciones distintas, dentro del límite de 1-3 opciones de FR-002 (ver FR-005).

## Requirements (mandatory)

### Functional Requirements

- FR-001: El sistema DEBE hacer que cada uno de los 8 skills del flujo secuencial con siguiente paso definido (`constitution`, `product-spec`, `tech-spec`, `roadmap`, `specify-feature`, `clarify-feature`, `plan-feature`, `implement-feature`) muestre, al finalizar su ejecución con éxito, un bloque visual destacado sugiriendo el/los siguiente(s) skill(s) a ejecutar; `clean-feature` queda excluido de forma intencionada por ser el último paso de la secuencia (ver FR-006).
- FR-002: El bloque de sugerencia DEBE presentar entre 1 y 3 opciones, cada una acompañada de un emoji.
- FR-003: El tono y formato del bloque de sugerencia DEBEN ser consistentes con el principio de diseño "Direct, jargon-free tone" ("Keep it AIsy") descrito en `specs/product-spec.md`.
- FR-004: Los skills `new-issue` y `grill-me` DEBEN quedar explícitamente excluidos de mostrar el bloque de sugerencia de siguiente paso, al no pertenecer a una secuencia fija.
- FR-005: El sistema DEBE determinar el/los siguiente(s) skill(s) sugerido(s) mediante un mapeo fijo y documentado por skill (no inferencia dinámica del estado del repo), según la siguiente secuencia principal:

  | Skill que finaliza | Siguiente(s) skill(s) sugerido(s) |
  |---|---|
  | `constitution` | `roadmap` (opcional, se puede saltar) / `specify-feature` |
  | `product-spec` (ejecutado por separado, sin pasar por `constitution`) | `tech-spec` |
  | `tech-spec` | `roadmap` (opcional, se puede saltar) / `specify-feature` |
  | `roadmap` | `specify-feature` |
  | `specify-feature` | `clarify-feature` (opcional, se puede saltar) / `plan-feature` |
  | `clarify-feature` | `plan-feature` |
  | `plan-feature` | `implement-feature` |
  | `implement-feature` | `clean-feature` |
  | `clean-feature` | (ninguno, ver FR-006) |

  Nota: `constitution` ya ejecuta internamente `product-spec` y `tech-spec` en cadena (ver `ai-toolkit/default/commands/constitution.md`), por lo que su bloque de sugerencia apunta al paso posterior a `tech-spec`, no a `product-spec`. La fila de `product-spec` de esta tabla aplica solo cuando el usuario ejecuta ese skill de forma independiente (sin pasar por `constitution`), típicamente cuando prefiere avanzar la constitución del proyecto paso a paso.
- FR-006: El skill `clean-feature`, al finalizar con éxito, NO DEBE mostrar ningún bloque de sugerencia de siguiente paso, al ser el último paso de la secuencia principal sin un siguiente fijo.
- FR-007: Cuando un skill del flujo secuencial finaliza sin éxito (error, cancelación o resultado parcial), el sistema NO DEBE mostrar ningún bloque de sugerencia de siguiente paso.
- FR-008: Al completar esta feature, el sistema DEBE incluir un bump de versión del proyecto (badge `version-X.Y` en `README.md` y `README-ES.md`) reflejando la nueva entrega. Este requisito queda documentado aquí como parte del alcance de la feature; su implementación se planifica como tarea del `plan.md`, no se ejecuta durante la planificación.

### Key Entities (include if feature involves data)

No aplica: esta feature no introduce ni gestiona datos persistentes. Los conceptos relevantes son el propio "skill" (una unidad ejecutable ya existente en el catálogo) y el "mensaje de sugerencia de siguiente paso" (un bloque de salida textual/visual mostrado al finalizar un skill), ninguno de los cuales requiere modelado de atributos adicionales según la información disponible en la issue.

## Success Criteria (mandatory)

### Measurable Outcomes

- SC-001: El 100% de los 8 skills del flujo secuencial con siguiente paso definido (`constitution`, `product-spec`, `tech-spec`, `roadmap`, `specify-feature`, `clarify-feature`, `plan-feature`, `implement-feature`) muestran el bloque de sugerencia de siguiente paso al finalizar con éxito; `clean-feature` queda excluido de forma intencionada por ser el último paso de la secuencia (ver FR-006).
- SC-002: 0 de los 2 skills excluidos (`new-issue`, `grill-me`) muestran el bloque de sugerencia de siguiente paso.
- SC-003: Los usuarios reportan que, tras finalizar un skill del flujo secuencial, saben qué ejecutar a continuación sin necesidad de consultar documentación externa.
- SC-004: El formato y tono del bloque de sugerencia es percibido como consistente con la identidad "Keep it AIsy" del producto en las revisiones de contenido.

## Assumptions

- Se asume que los 9 skills listados en la issue como parte del flujo secuencial son exactamente esos y en ese orden, tal como se describen en el título y cuerpo de la issue.
- Se asume que los skills excluidos son `new-issue` y `grill-me`. `get-issues` (mencionado originalmente en la issue) ya no existe en el repo — fue sustituido por `specify-feature` — por lo que se elimina de la lista de exclusión.
- Los ficheros a modificar son exclusivamente los de `ai-toolkit/default/commands/*.md` (fuente de verdad del catálogo de skills, referenciada en `catalog.yaml`). Los ficheros equivalentes en `.claude/commands/` quedan fuera de alcance de esta feature.
- Se asume que el alcance de esta feature se limita al mensaje de cierre mostrado tras una ejecución exitosa de un skill del flujo secuencial, sin extenderse a otros mecanismos de notificación fuera del propio flujo del skill.
- Existe dependencia de `specs/product-spec.md` como fuente vigente de los Design Principles (incluyendo el tono "Keep it AIsy") que el bloque de sugerencia debe respetar.

