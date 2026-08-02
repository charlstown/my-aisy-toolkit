# Encadenar la generación del roadmap al final de constitution
Feature Branch: 006-constitution-chain-roadmap

Created: 2026-08-02

Status: Draft

Input: User description: "todos los issues abiertos"

## User Scenarios & Testing (mandatory)

### User Story 1 - Constitution genera roadmap automáticamente tras tech-spec (Priority: P1)

Como usuario que corre `/constitution` para fundar un proyecto, quiero que tras generarse `product-spec.md` y `tech-spec.md` en cadena, el skill continúe automáticamente generando `roadmap.md` sin que tenga que invocar `/roadmap` manualmente, para tener las tres specs fundacionales listas en una sola ejecución.

Why this priority: Es el objetivo central del issue #12 — hoy el usuario debe invocar `/roadmap` como paso manual opcional tras `constitution`, lo que rompe el flujo de "todo en una cadena" que ya existe entre `product-spec` y `tech-spec`.

Independent Test: Correr `/constitution` en un repo sin specs previos y verificar que al finalizar existen `specs/product-spec.md`, `specs/tech-spec.md` y `specs/roadmap.md`, sin que se haya pedido confirmación al usuario entre `tech-spec` y `roadmap`.

Acceptance Scenarios:

1. Given un repo sin `specs/product-spec.md`, `specs/tech-spec.md` ni `specs/roadmap.md`, When el usuario corre `/constitution`, Then se generan los tres archivos en orden estrictamente secuencial (`product-spec` → `tech-spec` → `roadmap`), sin `AskUserQuestion` intermedio antes de correr `roadmap`.
2. Given que `tech-spec.md` acaba de escribirse como Step 2, When arranca el Step 3, Then `constitution` ejecuta el skill `roadmap` en su totalidad y espera a que termine antes de continuar, confirmando que `specs/roadmap.md` fue escrito.

### User Story 2 - Step 0 detecta también roadmap.md existente (Priority: P1)

Como usuario que corre `/constitution` en un repo que ya tiene algunas specs generadas, quiero que el chequeo previo (Step 0) detecte también si `specs/roadmap.md` ya existe, para poder decidir si regenero todo, solo lo que falta, o cancelo.

Why this priority: Es un criterio de aceptación explícito del issue y depende del mismo cambio de flujo que la User Story 1; sin esto, el chequeo previo queda desalineado con el nuevo tercer paso.

Independent Test: Con distintas combinaciones de archivos existentes (ej. solo `product-spec.md`, o `product-spec.md` + `tech-spec.md`, o los tres), correr `/constitution` y verificar que Step 0 lista correctamente cuáles de los tres archivos (incluido `roadmap.md`) ya existen, y ofrece las opciones de regenerar todo / solo lo faltante / cancelar.

Acceptance Scenarios:

1. Given que `specs/product-spec.md` y `specs/tech-spec.md` existen pero `specs/roadmap.md` no, When el usuario corre `/constitution`, Then Step 0 detecta la ausencia de `roadmap.md` y la incluye en las opciones presentadas (regenerar todo / solo lo faltante / cancelar).
2. Given que los tres archivos (`product-spec.md`, `tech-spec.md`, `roadmap.md`) ya existen, When el usuario corre `/constitution`, Then Step 0 lo refleja en las opciones ofrecidas al usuario.

### User Story 3 - Resumen final actualizado (Priority: P2)

Como usuario que termina de correr `/constitution`, quiero que el resumen final muestre `✓ specs/roadmap.md` junto a los otros dos archivos generados, y que ya no me sugiera correr `/roadmap` manualmente, para que el resumen refleje con precisión lo que realmente ocurrió.

Why this priority: Es una consecuencia directa de encadenar `roadmap` automáticamente (User Story 1); sin este ajuste el resumen quedaría inconsistente con el nuevo comportamiento, aunque no bloquea la generación de los archivos en sí.

Independent Test: Correr `/constitution` de principio a fin y revisar el bloque de resumen final generado, verificando que lista los tres archivos con `✓` y que el siguiente paso sugerido es únicamente `/specify-feature`.

Acceptance Scenarios:

1. Given que `/constitution` completó los tres pasos (`product-spec`, `tech-spec`, `roadmap`), When se muestra el resumen final (actual Step 3, pasa a Step 4), Then se listan `✓ specs/product-spec.md`, `✓ specs/tech-spec.md` y `✓ specs/roadmap.md`.
2. Given el resumen final generado, When el usuario lo lee, Then no aparece ninguna sugerencia de correr `/roadmap` manualmente, y el siguiente paso sugerido es solo `/specify-feature`.

## Edge Cases

- Si el skill `roadmap` falla o no logra escribir `specs/roadmap.md` durante el Step 3 automático, `constitution` se detiene con error e informa al usuario del fallo, sin llegar al resumen final.
- Si el usuario, en Step 0, elige "solo lo faltante" y únicamente falta `roadmap.md` (product-spec y tech-spec ya existen), `constitution` salta directo a correr solo el Step 3 (`roadmap`) sobre los specs existentes, sin reejecutar `product-spec` ni `tech-spec`.

## Requirements (mandatory)

### Functional Requirements

- FR-001: Step 0 de `constitution` DEBE detectar la existencia de `specs/roadmap.md`, además de `specs/product-spec.md` y `specs/tech-spec.md`, e incluir ese resultado en las opciones ofrecidas al usuario (regenerar todo / solo lo faltante / cancelar).
- FR-002: Tras completar el Step 2 (`tech-spec`), `constitution` DEBE ejecutar automáticamente el skill `roadmap` en su totalidad como un nuevo Step 3, sin presentar un `AskUserQuestion` intermedio al usuario.
- FR-003: `constitution` DEBE esperar a que el skill `roadmap` termine su ejecución y confirmar que `specs/roadmap.md` fue escrito antes de continuar al paso siguiente.
- FR-004: El orden de ejecución de los tres skills DEBE mantenerse estrictamente secuencial (`product-spec` → `tech-spec` → `roadmap`), nunca en paralelo.
- FR-005: El skill `roadmap` se invoca en su totalidad sin que `constitution` le pase contexto manualmente, dado que `roadmap` ya lee `product-spec.md` y `tech-spec.md` por sí mismo (incluida la detección de PoCs en tech-spec para su Phase 0).
- FR-006: El bloque de resumen final de `constitution` (actual Step 3, renumerado a Step 4) DEBE marcar `✓ specs/roadmap.md` junto a `✓ specs/product-spec.md` y `✓ specs/tech-spec.md`.
- FR-007: El bloque de resumen final DEBE eliminar la sugerencia de correr `/roadmap` manualmente como paso opcional.
- FR-008: El siguiente paso sugerido en el resumen final DEBE pasar a ser únicamente `/specify-feature`.
- FR-009: Las dos copias del archivo del skill (`ai-toolkit/default/commands/constitution.md` como plantilla fuente y `.claude/commands/constitution.md` como copia instalada en este repo) DEBEN quedar sincronizadas tras implementar este cambio. `ai-toolkit/default/commands/constitution.md` es la fuente de verdad; la propagación a la copia instalada se hace ejecutando `setup-ai`.
- FR-010: Si el skill `roadmap` falla o no logra escribir `specs/roadmap.md` durante el Step 3 automático, `constitution` DEBE detenerse con error e informar al usuario, sin continuar al resumen final.
- FR-011: En Step 0, si la opción elegida es "solo lo faltante" y únicamente falta `specs/roadmap.md` (product-spec y tech-spec ya existen), `constitution` DEBE saltar directo a ejecutar solo el Step 3 (`roadmap`), sin reejecutar `product-spec` ni `tech-spec`.

### Key Entities (include if feature involves data)

- `specs/product-spec.md` — spec de producto generada en Step 1 de `constitution`.
- `specs/tech-spec.md` — spec técnica generada en Step 2 de `constitution`.
- `specs/roadmap.md` — roadmap del proyecto, generado en el nuevo Step 3 de `constitution`, organizado en fases (incluyendo una Phase 0 de PoCs si `tech-spec.md` las define).
- `ai-toolkit/default/commands/constitution.md` — plantilla fuente del skill `constitution`.
- `.claude/commands/constitution.md` — copia instalada del skill `constitution` en este repo.

## Success Criteria (mandatory)

### Measurable Outcomes

- SC-001: Al correr `/constitution` sin specs previos, se generan en orden `specs/product-spec.md` → `specs/tech-spec.md` → `specs/roadmap.md`, sin confirmación intermedia antes de correr `roadmap`.
- SC-002: Step 0 detecta la existencia de `roadmap.md` junto con `product-spec.md` y `tech-spec.md`, y lo incluye en las opciones de regenerar todo / solo lo faltante / cancelar.
- SC-003: El resumen final muestra `✓ specs/roadmap.md` junto a los otros dos archivos y ya no sugiere `/roadmap` como paso manual opcional.
- SC-004: Las dos copias del archivo del skill (`ai-toolkit/default/commands/constitution.md` y `.claude/commands/constitution.md`) quedan sincronizadas entre sí.

## Assumptions

- El skill `roadmap` ya es capaz de leer `product-spec.md` y `tech-spec.md` por sí mismo (incluida la detección de PoCs en tech-spec para su Phase 0), tal como indica el issue, por lo que no se asume ninguna modificación al skill `roadmap` en sí.
- El issue no pide cambiar el comportamiento de `product-spec` ni `tech-spec` como skills individuales, solo la orquestación que hace `constitution` sobre ellos.
