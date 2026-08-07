# Mejorar la explicación e instalación global de setup-ai
Feature Branch: 004-mejorar-la-explicacion-e-instalacion-global-de-set
Source Issue: https://github.com/charlstown/my-aisy-toolkit/issues/52

Created: 2026-08-07

Status: Draft

Input: User description: "Al ejecutar `setup-ai`, la pregunta final actual menciona guardar un lanzador opcional en una ruta local, sin explicar qué es ni su utilidad. Debe sustituirse por una presentación visual y clara del lanzador `setup-ai`, e instalarse globalmente tanto para Claude Code como para Codex, sin pedir elegir herramienta. Antes de pedir confirmación, `setup-ai` muestra un recuadro o tabla visual con el nombre `setup-ai` y una descripción de su propósito. La explicación indica que el lanzador permite actualizar y reinstalar las skills en cualquier repositorio del equipo. El lanzador se instala globalmente para Claude Code y Codex de forma predeterminada. La confirmación solicita únicamente autorizar la instalación global. Tras instalarlo, el usuario puede invocar `setup-ai` desde cualquier repositorio para actualizar o reinstalar las skills. La mejora se centra en hacer comprensible la última interacción de la skill de configuración y en dar acceso global al comando de mantenimiento."

## User Scenarios & Testing (mandatory)

### User Story 1 - Comprender e instalar el lanzador global (Priority: P1)

Como persona que ejecuta `setup-ai`, quiero ver una explicación clara del lanzador y autorizar su instalación global para poder actualizar o reinstalar las skills desde cualquier repositorio del equipo.

Why this priority: La mejora busca que la última interacción de configuración sea comprensible y habilite el acceso global al comando de mantenimiento.

Independent Test: Se puede probar ejecutando `setup-ai`, comprobando la información previa y la única confirmación de instalación global, y después invocando `setup-ai` desde otro repositorio para actualizar o reinstalar las skills.

Acceptance Scenarios:

1. Given que una persona ejecuta `setup-ai`, When llega a la última interacción antes de confirmar, Then ve un recuadro ASCII compatible con CLI con el nombre `setup-ai`, su propósito, su disponibilidad global para Claude Code y Codex y su uso para actualizar o reinstalar las skills.
2. Given que se muestra la información del lanzador, When la persona lee la explicación, Then entiende que se instala globalmente para Claude Code y Codex y que permite actualizar o reinstalar las skills desde cualquier repositorio del equipo.
3. Given que la persona termina de revisar la información, When recibe la confirmación, Then la pregunta solicita únicamente autorizar la instalación global y no elegir una herramienta concreta.
4. Given que la instalación global ha finalizado, When la persona se encuentra en cualquier repositorio del equipo, Then puede invocar `setup-ai` para actualizar o reinstalar las skills.

## Edge Cases

- Si no se detecta la ruta de instalación de Claude Code, Codex o ambos, la instalación global se detiene y se informa claramente de qué agentes no se detectaron.
- ¿Cómo se comunica el resultado cuando `setup-ai` se invoca desde un repositorio que no admite la actualización o reinstalación esperada?

## Requirements (mandatory)

### Functional Requirements

- FR-001: El sistema MUST mostrar, antes de solicitar confirmación, un recuadro ASCII compatible con CLI con el nombre `setup-ai`, una descripción clara de su propósito, su disponibilidad global para Claude Code y Codex y su uso para actualizar o reinstalar las skills.
- FR-002: El sistema MUST explicar que el lanzador permite actualizar y reinstalar las skills en cualquier repositorio del equipo.
- FR-003: El sistema MUST instalar el lanzador globalmente para Claude Code y Codex de forma predeterminada, sin pedir elegir herramienta.
- FR-004: El sistema MUST solicitar una confirmación que autorice únicamente la instalación global.
- FR-005: El sistema MUST eliminar la referencia a guardar el lanzador en `.agents/skills/setup-ai/SKILL.md`.
- FR-006: Users MUST be able to invocar `setup-ai` desde cualquier repositorio para actualizar o reinstalar las skills después de instalarlo.
- FR-007: El sistema MUST detener la instalación global cuando no detecte la ruta de instalación de Claude Code, Codex o ambos, e informar claramente de qué agentes no se detectaron.
- FR-008: Tras copiar el lanzador, el sistema MUST intentar detectar la skill global para cada agente; si no la detecta, MUST revisar y comunicar la causa.

## Success Criteria (mandatory)

### Measurable Outcomes

- SC-001: Antes de la confirmación, la ejecución de `setup-ai` muestra un elemento visual identificable con el nombre `setup-ai` y una descripción de su propósito.
- SC-002: La confirmación de la instalación no solicita seleccionar Claude Code ni Codex.
- SC-003: Tras una instalación global completada, `setup-ai` se puede invocar desde un repositorio distinto al de instalación para actualizar o reinstalar las skills.
- SC-004: El 100 % de las instalaciones en las que se detecten Claude Code y Codex finaliza con ambas skills globales detectables.

## Assumptions

- Las personas usuarias necesitan actualizar o reinstalar las skills desde repositorios del equipo distintos al repositorio de instalación.
- La mejora se limita a la última interacción de la skill de configuración y al acceso global al comando de mantenimiento.
- Claude Code y Codex son los únicos entornos de herramientas incluidos explícitamente en esta solicitud.
- La disponibilidad global se verifica detectando la skill tras copiarla para cada agente; si no se detecta, se revisa y comunica la causa.
