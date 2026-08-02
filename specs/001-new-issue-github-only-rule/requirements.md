# Documentar como regla mandatory que new-issue nunca escribe en el repo, solo en GitHub
Feature Branch: [001-new-issue-github-only-rule]

Created: 2026-08-02

Status: Draft

Input: User description: "todos los issues abiertos"

## User Scenarios & Testing (mandatory)

### User Story 1 - Regla mandatory de "solo GitHub" en new-issue (Priority: P1)

Como mantenedor del repo, quiero que la skill `new-issue` tenga documentada de forma explícita y con el mismo peso normativo que otras reglas "mandatory" (como la convención de título del issue) que su único permiso de escritura es sobre GitHub (creación de issues vía `gh issue create`), para que nunca cree, edite ni borre archivos del repositorio ni haga commits o pushes durante su ejecución.

Why this priority: Es el único objetivo del issue; sin esta regla documentada explícitamente, la skill solo cuenta con una indicación informal ("Do not write code. Do not do refactors. Do not open PRs") que no tiene el mismo peso normativo que otras reglas mandatory existentes, dejando ambigüedad sobre el alcance exacto de las herramientas de escritura prohibidas.

Independent Test: Se puede verificar leyendo `ai-toolkit/default/commands/new-issue.md` y `.claude/commands/new-issue.md` y confirmando que ambos contienen un bloque `mandatory` explícito que limita el único permiso de escritura de la skill a GitHub (`gh issue create`) y prohíbe explícitamente `Write`, `Edit`, `git commit` y `git push` sobre ficheros del repo.

Acceptance Scenarios:

1. Given el fichero `ai-toolkit/default/commands/new-issue.md`, When se revisan sus instrucciones, Then existe un bloque `mandatory` explícito que indica que el único permiso de escritura de la skill es GitHub (`gh issue create`), nunca el repositorio.
2. Given el fichero `.claude/commands/new-issue.md`, When se revisan sus instrucciones, Then existe el mismo bloque `mandatory` explícito, sincronizado con la copia de `ai-toolkit/default/commands/new-issue.md`.
3. Given el bloque `mandatory` en cualquiera de las dos copias, When se lee su contenido, Then prohíbe explícitamente el uso de `Write`, `Edit`, `git commit` y `git push` sobre ficheros del repositorio durante la ejecución de la skill.
4. Given las dos copias del fichero tras el cambio, When se comparan entre sí, Then quedan sincronizadas (mismo contenido para el bloque `mandatory` añadido).

## Edge Cases

- El issue no describe ningún comportamiento runtime nuevo (no se pide bloquear herramientas técnicamente, solo documentar la regla); no aplican edge cases de ejecución.

## Requirements (mandatory)

### Functional Requirements

- FR-001: Las instrucciones de `ai-toolkit/default/commands/new-issue.md` DEBEN incluir un bloque `mandatory` explícito que establezca que el único permiso de escritura de la skill es GitHub (creación de issues vía `gh issue create`), nunca el repositorio.
- FR-002: Las instrucciones de `.claude/commands/new-issue.md` DEBEN incluir el mismo bloque `mandatory` explícito descrito en FR-001.
- FR-003: El bloque `mandatory` DEBE prohibir explícitamente el uso de `Write`, `Edit`, `git commit` y `git push` sobre ficheros del repositorio durante la ejecución de la skill `new-issue`.
- FR-004: Ambas copias del fichero (`ai-toolkit/default/commands/new-issue.md` y `.claude/commands/new-issue.md`) DEBEN quedar sincronizadas tras aplicar el cambio.
- FR-005: El bloque `mandatory` DEBE añadirse al inicio del fichero, como primer bloque `mandatory`, antes de cualquier otra instrucción.
- FR-006: El bloque `mandatory` también DEBE propagarse a la copia externa mantenida por el usuario en su Vault, bajo `setup-ai/templates` (fuente adicional fuera de este repositorio, distinta de las dos copias nombradas explícitamente en el issue).

### Key Entities (include if feature involves data)

- No aplica: este issue es puramente documental (añadir una regla mandatory a las instrucciones de una skill), no involucra entidades de datos.

## Success Criteria (mandatory)

### Measurable Outcomes

- SC-001: Al inspeccionar `ai-toolkit/default/commands/new-issue.md`, un revisor puede identificar sin ambigüedad un bloque `mandatory` que restringe la escritura de la skill exclusivamente a GitHub.
- SC-002: Al inspeccionar `.claude/commands/new-issue.md`, un revisor puede identificar el mismo bloque `mandatory` presente en la otra copia, con contenido equivalente.
- SC-003: Ningún acceptance criterion del issue #21 queda sin marcar tras la implementación (los tres checkboxes del issue quedan satisfechos).

## Assumptions

- Se asume que "ambas copias" del issue se refiere a los dos ficheros nombrados explícitamente en el issue (`ai-toolkit/default/commands/new-issue.md` y `.claude/commands/new-issue.md`), ambos existentes en este mismo repositorio. Adicionalmente, el usuario confirmó que existe una tercera copia externa a este repositorio, en su Vault personal bajo `setup-ai/templates`, que también debe recibir el mismo bloque `mandatory` (ver FR-006).
