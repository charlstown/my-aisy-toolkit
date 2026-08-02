# specify-feature debe incluir el link del issue de GitHub en requirements.md
Feature Branch: 005-specify-feature-issue-link

Created: 2026-08-02

Status: Draft

Input: User description: "todos los issues abiertos"

## User Scenarios & Testing (mandatory)

### User Story 1 - Trazabilidad del issue origen en requirements.md (Priority: P1)

Como usuario que ejecuta `/specify-feature` a partir de un issue de GitHub (ya sea pegando la URL de un issue único en Step 1a, o seleccionándolo de un listado de issues abiertos en Step 1c), quiero que el `requirements.md` generado incluya un campo explícito y separado con el link completo del issue, para poder rastrear hacia atrás qué issue originó la especificación sin tener que buscarlo dentro del texto libre de `Input: User description`.

Why this priority: Es el único comportamiento pedido por el issue; sin él, otras skills (como `clean-feature`) dependen de que el número de issue aparezca "por casualidad" dentro del texto libre, lo cual es frágil y no confiable.

Independent Test: Ejecutar `/specify-feature` con la URL de un issue de GitHub (o seleccionando uno del listado de abiertos) y verificar que el `requirements.md` resultante contiene un campo etiquetado con el link completo y navegable del issue, separado del bloque `Input: User description`.

Acceptance Scenarios:

1. Given un usuario ejecuta `/specify-feature` pasando la URL de un issue de GitHub único (Step 1a), When se genera el `requirements.md` en Step 4, Then el documento incluye un campo explícito con el link completo del issue (por ejemplo `Source Issue: https://github.com/{owner}/{repo}/issues/{n}`), claramente separado del texto libre de `Input: User description`.
2. Given un usuario ejecuta `/specify-feature` y selecciona un issue del listado de issues abiertos (Step 1c), When se genera el `requirements.md` en Step 4, Then el documento incluye ese mismo campo explícito con el link completo del issue seleccionado.
3. Given un usuario ejecuta `/specify-feature` a partir de una fuente que no es un issue de GitHub (archivo, roadmap, prompt libre, URL genérica), When se genera el `requirements.md`, Then el campo del link del issue se omite por completo, sin inventar ni inferir una URL.

## Edge Cases

- ...

## Requirements (mandatory)

### Functional Requirements

- FR-001: Cuando la fuente detectada en Step 1 de `/specify-feature` sea un issue de GitHub (single issue vía URL, o issue elegido del listado de issues abiertos), el `requirements.md` generado en Step 4 DEBE incluir un campo explícito y claramente etiquetado con el link completo del issue (por ejemplo, justo debajo de `Feature Branch` o de `Input`), con el formato `Source Issue: https://github.com/{owner}/{repo}/issues/{n}` (traducido si corresponde al idioma del usuario).
- FR-002: El campo del link del issue DEBE contener la URL completa navegable del issue, no solo el número.
- FR-003: El campo del link del issue DEBE estar claramente separado del texto libre de `Input: User description`.
- FR-004: Cuando la fuente NO sea un issue de GitHub (archivo, roadmap, prompt libre, URL genérica), el campo DEBE omitirse; no se debe inventar ni inferir un link.
- FR-005: El nuevo campo DEBE ser compatible con la detección actual de `issue_num_{folder}` que realiza `clean-feature` (Step 2), haciendo esa detección más confiable en lugar de depender de que el número aparezca por casualidad en texto libre.
- FR-006: El template del comando DEBE quedar actualizado tanto en `ai-toolkit/default/commands/specify-feature.md` como sincronizado en `.claude/commands/specify-feature.md`; no bloquea a que el issue #12 se resuelva primero — la sincronización entre ambas copias se apoya en el mismo mecanismo (`setup-ai`) usado en el resto de features del toolkit.

### Key Entities (include if feature involves data)

- ...

## Success Criteria (mandatory)

### Measurable Outcomes

- SC-001: Al correr `/specify-feature` con la URL de un issue de GitHub (o seleccionando uno del listado de issues abiertos), el `requirements.md` generado incluye un campo explícito con el link completo del issue.
- SC-002: Al generar `requirements.md` desde una fuente que no es un issue de GitHub (archivo, roadmap, prompt), el campo no aparece.
- SC-003: El template queda actualizado en `ai-toolkit/default/commands/specify-feature.md` y sincronizado en `.claude/commands/specify-feature.md`.

## Assumptions

- ...
