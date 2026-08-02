# Eliminar grill-me del catálogo de skills y de la instalación por defecto
Feature Branch: 002-remove-grill-me-from-default-profile

Created: 2026-08-02

Status: Draft

Input: User description: "todos los issues abiertos"

## User Scenarios & Testing (mandatory)

### User Story 1 - Un repo nuevo instalado con setup-ai no incluye /grill-me (Priority: P1)

Como mantenedor del toolkit, cuando instalo o actualizo un repo con `setup-ai` usando el perfil `default`, no quiero que se instale el comando/skill `/grill-me`, porque deja de formar parte del perfil `default`.

Why this priority: Es el comportamiento central solicitado por el issue: `grill-me` deja de formar parte del perfil `default` en `catalog.yaml`, por lo que `setup-ai` ya no lo instalará en nuevos repos.

Independent Test: Ejecutar `setup-ai` con el perfil `default` sobre un repo nuevo o ya existente y verificar que no aparece el fichero `.claude/commands/grill-me.md` ni el comando `/grill-me` tras la instalación/actualización.

Acceptance Scenarios:

1. Given `catalog.yaml` con el perfil `default` ya sin la entrada `grill-me.md`, When se ejecuta `setup-ai` sobre un repo nuevo, Then el repo resultante no contiene `.claude/commands/grill-me.md`.
2. Given un repo ya instalado previamente con `grill-me` (versión anterior del toolkit), When se actualiza mediante `setup-ai` con el perfil `default`, Then `/grill-me` deja de estar disponible en ese repo.

### User Story 2 - Los ficheros de la skill grill-me se eliminan físicamente del toolkit (Priority: P1)

Como mantenedor del toolkit, quiero que los ficheros fuente de la skill `grill-me` desaparezcan del repo `my-aisy-toolkit`, para que no queden artefactos huérfanos ni referencias a una skill retirada.

Why this priority: Es un criterio de aceptación explícito del issue y condición previa para que `setup-ai` no pueda instalarla.

Independent Test: Comprobar que `ai-toolkit/default/commands/grill-me.md` y `.claude/commands/grill-me.md` no existen en el árbol del repo tras aplicar el cambio.

Acceptance Scenarios:

1. Given el repo antes del cambio con `ai-toolkit/default/commands/grill-me.md` y `.claude/commands/grill-me.md` presentes, When se aplica el cambio, Then ambos ficheros dejan de existir en el repo.

### User Story 3 - La documentación del toolkit deja de listar /grill-me como skill disponible (Priority: P2)

Como usuario que consulta la documentación del toolkit (README, README-ES, CHANGELOG, product-spec), quiero que ya no se liste `/grill-me` como skill disponible, para que la documentación refleje el catálogo real de skills instalables.

Why this priority: Es un criterio de aceptación explícito del issue, aunque de menor impacto funcional que la eliminación efectiva de la instalación y los ficheros (no bloquea el comportamiento de `setup-ai`, pero sí evita documentación inconsistente).

Independent Test: Revisar `README.md`, `README-ES.md`, `CHANGELOG.md` y `specs/product-spec.md` y confirmar que ninguno lista `/grill-me` como skill disponible/instalable.

Acceptance Scenarios:

1. Given `README.md` y `README-ES.md` listando actualmente `/grill-me` entre las skills disponibles, When se aplica el cambio, Then esa entrada se actualiza o elimina de ambos ficheros.
2. Given `CHANGELOG.md` y `specs/product-spec.md` con referencias a `/grill-me`, When se aplica el cambio, Then dichas referencias se actualizan o eliminan conforme a lo que corresponda documentalmente.

## Edge Cases

- Repos que ya tienen `/grill-me` instalado desde una versión anterior del toolkit: `setup-ai` NUNCA borra skills preexistentes que el usuario ya tuviera — este es un principio general del toolkit (instalar/actualizar únicamente añade o actualiza las skills propias del catálogo, nunca elimina lo que el usuario ya tenía). Por tanto, `setup-ai` simplemente deja de reinstalar o mantener `/grill-me` en adelante; no la desinstala activamente de repos ya existentes.
- Mención de `grill-me` en `specify-feature.md`: se ajusta/elimina, ya que deja de tener sentido como comparación funcional una vez retirada del perfil `default`.
- Mención de `grill-me` en `clarify-feature.md`: se deja tal cual, como referencia histórica/comparativa.

## Requirements (mandatory)

### Functional Requirements

- FR-001: `catalog.yaml` no debe listar `ai-toolkit/default/commands/grill-me.md` (ni ninguna referencia a `grill-me.md`) en el perfil `default`.
- FR-002: El fichero `ai-toolkit/default/commands/grill-me.md` debe eliminarse del repo.
- FR-003: El fichero `.claude/commands/grill-me.md` debe eliminarse del repo.
- FR-004: `README.md` no debe listar `/grill-me` como skill disponible.
- FR-005: `README-ES.md` no debe listar `/grill-me` como skill disponible.
- FR-006: `CHANGELOG.md` debe actualizarse o eliminar las referencias a `/grill-me` como skill listada/disponible.
- FR-007: `specs/product-spec.md` debe actualizarse o eliminar las referencias a `/grill-me` como skill listada/disponible.
- FR-008: Un repo nuevo o actualizado mediante `setup-ai` con el perfil `default` no debe incluir el comando/skill `/grill-me` tras la instalación.
- FR-009: `setup-ai` NUNCA debe borrar activamente `/grill-me` (ni ninguna otra skill) de un repo que ya la tuviera instalada de una versión anterior; el alcance se limita a que futuras instalaciones/actualizaciones no la reinstalen ni la mantengan — principio general: `setup-ai` solo añade o actualiza sus propias skills, nunca elimina lo que el usuario ya tenía.
- FR-010: La mención comparativa a `grill-me` en `ai-toolkit/default/commands/specify-feature.md` (y su copia instalada) debe ajustarse o eliminarse, ya que deja de tener sentido tras retirar la skill del perfil `default`.
- FR-011: La mención comparativa a `grill-me` en `ai-toolkit/default/commands/clarify-feature.md` (y su copia instalada) se mantiene tal cual, como referencia histórica.

### Key Entities (include if feature involves data)

No aplica: la feature consiste en eliminar ficheros y referencias documentales de una skill existente, no en modelar ni modificar datos.

## Success Criteria (mandatory)

### Measurable Outcomes

- SC-001: `catalog.yaml` no contiene ninguna ocurrencia de `grill-me.md` en el perfil `default`.
- SC-002: Los ficheros `ai-toolkit/default/commands/grill-me.md` y `.claude/commands/grill-me.md` no existen en el repo.
- SC-003: `README.md`, `README-ES.md`, `CHANGELOG.md` y `specs/product-spec.md` no listan `/grill-me` como skill disponible.
- SC-004: Una instalación de `setup-ai` con perfil `default` sobre un repo nuevo no produce el fichero `.claude/commands/grill-me.md`.

## Assumptions

- Se asume que "eliminar del perfil default" en `catalog.yaml` significa quitar la entrada `grill-me.md` de la lista de ficheros de ese perfil, sin que el issue indique cambios en otros perfiles (si existieran).
- Se asume que la skill `grill-me` en sí (el concepto/funcionalidad) no se elimina de forma global del toolkit, solo se retira del perfil `default` y de los ficheros físicos indicados en el issue; el issue no menciona otros perfiles ni un catálogo de skills más amplio fuera del `default`.
